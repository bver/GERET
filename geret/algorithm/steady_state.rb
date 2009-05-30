
require 'algorithm/algorithm_base'
require 'algorithm/breed_individual'

class SteadyState < AlgorithmBase

  include BreedIndividual 
 
  def setup config
    super

    @replacement = @cfg['replacement_rank'].nil? ? 
                 @cfg.factory('replacement') : 
                 @cfg.factory('replacement', @cfg.factory('replacement_rank') ) 

    @report.next   
    return @report    
  end

  def step
    @report.next    
    @report << "--------- step #{@steps += 1}"
    @report.report @population

    @cross, @injections, @mutate, @copies = 0, 0, 0, 0   
    @population_size.times do
      @selection.population = @population
      
      individual = breed_individual @selection 
      next unless individual.valid?

      bad = @replacement.select_one @population
      @population.delete bad
      @population << individual
    end

    @report['numof_crossovers'] << @cross   
    @report['numof_injections'] << @injections
    @report['numof_copies'] << @copies
    @report['numof_mutations'] << @mutate
   
    return @report
  end

end

