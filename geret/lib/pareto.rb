
module Pareto
  Objective = Struct.new( 'Objective', :symb, :how )
  @@objectives = {}

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

  def dominates? other
    dominates_core( other, false )
  end
  
  def <=>(other)
    if dominates? other
      return -1
    else
      return 1 if other.dominates? self
      return 0
    end
  end

  def Pareto.minimize( user, symb ) 
    Pareto.objective( user, symb, :minimize )   
  end

  def Pareto.maximize( user, symb ) 
    Pareto.objective( user, symb, :maximize )   
  end
 
  def Pareto.objective_symbols user
    @@objectives.fetch( user.to_s ).map { |obj| obj.symb }
  end

  def objective_symbols
    Pareto.objective_symbols self.class
  end

  def Pareto.objective_sort( population, user, symb )
    objective = @@objectives.fetch( user.to_s ).find { |obj| obj.symb == symb }  
    population.sort { |a,b| objective.how.call( b.send(objective.symb), a.send(objective.symb) ) }
  end

  def Pareto.objective_best( population, user, symb )
    objective = @@objectives.fetch( user.to_s ).find { |obj| obj.symb == symb }  
    population.min { |a,b| objective.how.call( b.send(objective.symb), a.send(objective.symb) ) }
  end

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

module WeakPareto
  include Pareto

  def dominates? other
    dominates_core( other, true )
  end
 
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

