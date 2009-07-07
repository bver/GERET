
module Moea

# The infrastructure for the multiobjective optimisation. 
# See http://dces.essex.ac.uk/staff/rpoli/gp-field-guide/92KeepingtheObjectivesSeparate.html 
#
# The user-defined class can include Pareto module which 
# 1. brings the dominates? method and <=> operator,
# 2. offers the supporting methods for the Crowding distance computation,
# 
# Class methods Pareto.nondominated and Pareto.dominated implement selections from the array of Pareto-aware instances.
#
module Pareto
  Objective = Struct.new( 'Objective', :symb, :how )
  @@objectives = {}

  # Declare the objective in the user-defined class.
  #   user .. the name of the user-defined class
  #   symb .. symbol (an accessor) of the single objective
  #   dir .. direction of the optimisation. 
  #   
  # The possible values of dir are:
  #   :maximize .. the objective should be maximized (the individual with a greater symb value is better)
  #   :minimize .. the objective should be minimized (the individual with a smaller symb value is better) 
  #   proc { |a,b| ... } .. (procedure returns -1 if a is better than b, returns 1 if b is better than a, returns 0 if a and b cannot be distinguished)
  #   
  # For instance:
  #   class BasicPair < Struct.new( :up, :down )
  #     include Pareto
  #     Pareto.objective BasicPair, :down, :minimize
  #     Pareto.objective BasicPair, :up, :maximize 
  #   end
  #   
  # declares the user-defined BasicPair structure with two objectives (:up, :down).
  # BasicPair#up is maximized and BasicPair#down is minimized.
  # The BasicPair#dominates? and BasicPair#<=> are now defined for the use within the library,
  # BasicPair.objective si
  # 
  def Pareto.objective( user, symb, dir )
    
    how = case dir
    when :maximize
      proc { |a,b| a<=>b }
    when :minimize
      proc { |a,b| b<=>a }     
    else
      dir
    end

    objs = @@objectives.fetch( user.to_s, [] )
    objs.push Objective.new( symb, how )
    @@objectives[user.to_s] = objs
  end

  # Given that a and b are individuals of the same class, a.dominates?(b) returns true if:
  # 1. there is no such objective in which the b is better than a, and
  # 2. there is at least one objective in which the a is better than b.
  def dominates? other
    dominates_core( other, false )
  end
  
  # a<=>b returns: 
  #   -1 if a.dominates? b,
  #   1 if b.dominates? a,
  #   0 otherwise.
  # Note: Assuming that if x dominates y then y does not dominate x (see WeakPareto module).
  def <=>(other)
    return -1 if dominates? other
    return 1 if other.dominates? self
    return 0
  end

  # Shorthand for
  #   Pareto.objective( user, symb, :minimize ) 
  def Pareto.minimize( user, symb ) 
    Pareto.objective( user, symb, :minimize )   
  end

  # Shorthand for
  #   Pareto.objective( user, symb, :maximize ) 
  def Pareto.maximize( user, symb ) 
    Pareto.objective( user, symb, :maximize )   
  end
 
  # Return the array of all objective symbols declared by the Pareto.objective for the class user.
  def Pareto.objective_symbols user
    @@objectives.fetch( user.to_s ).map { |obj| obj.symb }
  end

  # Shorthand for 
  #   Pareto.objective_symbols( self.class )
  def objective_symbols
    Pareto.objective_symbols self.class
  end

  # Return the population sorted by the symb objective of the user class.
  def Pareto.objective_sort( population, user, symb )
    objective = @@objectives.fetch( user.to_s ).find { |obj| obj.symb == symb }  
    population.sort { |a,b| objective.how.call( b.send(objective.symb), a.send(objective.symb) ) }
  end

  # Return the best member of the population (by the means of symb objective of the user class). 
  def Pareto.objective_best( population, user, symb )
    objective = @@objectives.fetch( user.to_s ).find { |obj| obj.symb == symb }  
    population.min { |a,b| objective.how.call( b.send(objective.symb), a.send(objective.symb) ) }
  end

  # Return the nondominated subset of the population.
  # For each member M of the nondominated subset holds that there is no other member of the population dominating M.
  def Pareto.nondominated population
    front = []
    population.each_with_index do |individual1, index1|
      nondominated = true
      population.each_with_index do |individual2, index2|
        next if index1==index2
        if individual2.dominates? individual1
          nondominated = false
          break
        end
      end
      front.push individual1 if nondominated
    end
    front
  end

  # Return the dominated subset of the population, ie. the population with Pareto.nondominated members excluded.
  def Pareto.dominated population
    dominated = []
    population.each_with_index do |individual1, index1|
      population.each_with_index do |individual2, index2|
        next if index1==index2
        if individual2.dominates? individual1
          dominated.push individual1
          break
        end
      end
    end
    dominated
  end
 
#--
#
#  faster, but assuming a.dominates?(b) -> !b.dominates?(a) which is not ok for weak pareto dominance:
#  def Pareto.nondominated selection
#      front = []
#      selection.each do |individual|
#
#        next if front.detect { |f| f.dominates? individual }
#
#        removal = []
#        front.each do |f|
#          next unless individual.dominates? f
#          removal.push f
#        end
#        removal.each { |r| front.delete r }
#
#        front.push individual
#      end
#
#      front
#  end
#
#++  
 
  protected

  def dominates_core( other, domination )
    @@objectives.fetch(self.class.to_s).each do |obj| 
      first = send obj.symb
      second = other.send obj.symb 

      case obj.how.call( first, second )
      when 1
        domination = true
      when -1
        return false
      end
    end
    return domination
  end

end

# The Weak Pareto optimality support.
# It offers the same functionality as the Pareto module, with the different dominates? method.
#
# See https://eprints.kfupm.edu.sa/52319/1/52319.pdf 
#
module WeakPareto
  include Pareto

  # Given that a and b are individuals of the same class, a.dominates?(b) returns true if
  # there is no such objective in which the b is better than a. 
  def dominates? other
    dominates_core( other, true )
  end

  # a<=>b returns: 
  #   -1 if a dominates b and b does not dominate a,
  #   1 if b dominates a and a does not dominate b,
  #   0 otherwise.
  def <=>(other)
    if dominates? other
      return 0 if other.dominates? self
      return -1
    else
      return 1 if other.dominates? self
      return 0
    end
  end
end

end # Moea

