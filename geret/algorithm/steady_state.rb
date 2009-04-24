
require 'algorithm/single_objective'

class SteadyState < SingleObjective

  def setup config
    super

    @replacement = @cfg['replacement_rank'].nil? ? 
                 @cfg.factory('replacement') : 
                 @cfg.factory('replacement', @cfg.factory('replacement_rank') ) 
   
    return @report    
  end

  def step
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
   
    @report.next   
    return @report
  end

end

