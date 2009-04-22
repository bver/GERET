
require 'algorithm/single_objective'

class Generational < SingleObjective

  attr_accessor :elite_size

  def setup config
    super
    raise "Generational: elite_size >= population_size" if @elite_size >= @population_size

    @elite_rank = @cfg.factory('elite_rank')     
    return @report    
  end

  def step
    @report << "--------- step #{@steps += 1}" 

    ranked_population = ( @elite_rank.rank @population ).map { |ranked| ranked.original }
    @report.report ranked_population
       
    new_population = ranked_population[0...@elite_size]  
    @selection.population = @population  

    @cross, @injections, @mutate, @copies = 0, 0, 0, 0
    while new_population.size < @population_size
      individual = breed_individual
      new_population << individual if individual.valid?
    end

    @report['numof_crossovers'] << @cross   
    @report['numof_injections'] << @injections
    @report['numof_copies'] << @copies
    @report['numof_mutations'] << @mutate

    @population = new_population

    @report.next   
    return @report
  end

end

