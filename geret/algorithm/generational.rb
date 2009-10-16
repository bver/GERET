
require 'algorithm/algorithm_base'
require 'algorithm/elitism'
require 'algorithm/breed_individual'

class Generational < AlgorithmBase

  include Elitism
  include BreedIndividual 

  def setup config
    super
    init_elitism @population_size
    @report.next    
    return @report    
  end

  def step
    @report.next    
    @report << "--------- step #{@steps += 1}" 
    @report.report @population 

    parent_population = @selection.select( @population_size - @elite_size, @population )
    new_population = breed_population( parent_population, @population_size - @elite_size )
    new_population.concat elite( @population )

    @report['numof_crossovers'] << @cross   
    @report['numof_injections'] << @injections
    @report['numof_copies'] << @copies
    @report['numof_mutations'] << @mutate

    @population = new_population

    return @report
  end

end

