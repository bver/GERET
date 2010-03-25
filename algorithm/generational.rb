
require 'algorithm/support/algorithm_base'
require 'algorithm/support/elitism'
require 'algorithm/support/breed'
require 'algorithm/support/phenotypic_truncation'

class Generational < AlgorithmBase

  include Elitism
  include Breed 
  include PhenotypicTruncation

  def setup config
    super
    @population = load_or_init( @store, @population_size )   
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
    new_population = eliminate_duplicates new_population if @duplicate_elimination
    @population = new_population

    return @report
  end

end

