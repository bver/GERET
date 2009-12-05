require 'lib/pareto'

module Moea

# Crowding distance computation class for preserving good spread of the pareto front (diversity of MOEA solutions).
# Fully described in the original NSGA-II paper:
# http://ieeexplore.ieee.org/xpl/freeabs_all.jsp?arnumber=996017 or
# http://sci2s.ugr.es/docencia/doctobio/2002-6-2-DEB-NSGA-II.pdf
#
class Crowding
  Inf = 1.0/0.0
  CrowdingFields = Struct.new( 'CrowdingFields', :original, :cdist, :index )

  # Compute the crowding distance for each member of the population.
  # There are two variants:
  #   population2 = Crowding.distance population
  #     where population2[i].original is the original population[i] member, population2[i].cdist is the crowding distance, or:
  #
  #   Crowding.distance( population ) { |member, cdist| .... }
  #     2-argument of the block are: the original population member, cdist is the associated crowding distance.
  #     
  # The Crowding.distance method assumes: 
  #   1. the population is the Enumerable container of individuals, and 
  #   2. the method individual.dominates?( other ) returning true if the individual dominates other one, and
  #   3. the method individual.objective_symbols returning the enumerable with symbols for accessing objective values
  #        (See Pareto#objective_symbols method)
  #   
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

    result.sort! { |a,b| a.index <=> b.index }
    return result unless block_given?
    result.map { |individual| yield( population[individual.index], individual.cdist ) }
  end

end

end # Moea

