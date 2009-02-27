
module Pareto
  Objective = Struct.new( 'Objective', :symb, :how )
  @@objectives = {}

  def Pareto.objective( user, symb, how )
    objs = @@objectives.fetch( user.to_s, [] )
    objs.push Objective.new( symb, how )
    @@objectives[user.to_s] = objs
  end
 
  def <=>(other)
    if dominates? other
      return 1
    else
      return -1 if other.dominates? self
      return 0
    end
  end

  def dominates? other
    domination = false
    @@objectives.fetch(self.class.to_s).each do |obj| 
      if obj.how == :maximize
        first = send obj.symb
        second = other.send obj.symb 
      else
        first = other.send obj.symb
        second = send obj.symb 
      end 



      case first<=>second
      when 1
        domination = true
      when -1
        return false
      end
    end
    return domination
  end

#  def objective_maximize( *symbs )
#  end

#  def objective_minimize( *symbs )
#  end

end

