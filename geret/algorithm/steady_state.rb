
require 'algorithm/support/algorithm_base'
require 'algorithm/support/breed'

class SteadyState < AlgorithmBase

  include Breed
 
  def setup config
    super

    @replacement = @cfg['replacement_rank'].nil? ? 
                 @cfg.factory('replacement') : 
                 @cfg.factory('replacement', @cfg.factory('replacement_rank') ) 

    @population = load_or_init( @store, @population_size )  

    @report.next   
    return @report    
  end

  def step
    @report.next    
    @report << "--------- step #{@steps += 1}"
    @report.report @population

    @cross, @injections, @mutate = 0, 0, 0  
    @population_size.times do
      @selection.population = @population
      
      individual = breed_individual @selection 

      bad = @replacement.select_one @population
      @population.delete bad
      @population << individual
    end

    @report['numof_crossovers'] << @cross   
    @report['numof_injections'] << @injections
    @report['numof_mutations'] << @mutate
   
    return @report
  end

end

