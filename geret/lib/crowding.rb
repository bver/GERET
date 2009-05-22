require 'lib/pareto'

class Crowding
  Inf = 1.0/0.0
  CrowdingFields = Struct.new( 'CrowdingFields', :original, :cdist, :index )

  def Crowding.distance population
    raise "Crowding: cannot compute empty population" if population.empty? 
    result = []
    population.each_with_index { |orig,i| result.push CrowdingFields.new( orig, 0.0, i ) }
    
    population.first.objective_symbols.each do |obj|
      result.sort! { |a,b| a.original.send(obj) <=> b.original.send(obj) }
      norm = result.last.original.send(obj).to_f - result.first.original.send(obj).to_f 
      result.first.cdist = result.last.cdist = Inf
      for i in 1...(population.size-1)
        result[i].cdist += (( result[i+1].original.send(obj) - result[i-1].original.send(obj) ) / norm )
      end
    end

    if block_given?
      result.each { |individual| yield( population[individual.index], individual.cdist ) }
      return population
    else
      return result.sort { |a,b| a.index <=> b.index }
    end 
  end

end
