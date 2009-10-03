
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

    new_population = elite @population

    @selection.population = @population  

    @cross, @injections, @mutate, @copies = 0, 0, 0, 0
    while new_population.size < @population_size
      individual = breed_individual @selection 
      new_population << individual if individual.valid?
    end

    @evaluator.run new_population if defined? @evaluator

    @report['numof_crossovers'] << @cross   
    @report['numof_injections'] << @injections
    @report['numof_copies'] << @copies
    @report['numof_mutations'] << @mutate

    @population = new_population

    return @report
  end

end

