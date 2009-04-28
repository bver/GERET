
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
 
  def <=>(other)
    if dominates? other
      return -1
    else
      return 1 if other.dominates? self
      return 0
    end
  end

  def dominates? other
    domination = false
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

