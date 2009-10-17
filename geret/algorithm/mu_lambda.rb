
require 'algorithm/algorithm_base'
require 'algorithm/elitism'
require 'algorithm/breed_individual'

class MuLambda < AlgorithmBase

  include Elitism
  include BreedIndividual
  
  attr_accessor :comma_or_plus, :lambda_size

  def setup config
    super
    raise "MuLambda: lambda_size < population_size" if @comma_or_plus == 'comma' and @lambda_size < @population_size
    @population = load_or_init( @store, @population_size )   
    init_elitism @population_size
    @report.next    
    return @report    
  end

  def step
    @report.next    
    @report << "--------- step #{@steps += 1}" 
    @report.report @population

    lambda_population = breed_population( Util.permutate( @population ), @lambda_size )
    elite_population = elite @population

    lambda_population.concat @population if @comma_or_plus == 'plus'

    @population = @selection.select( @population_size - elite_population.size, lambda_population )
    @population.concat elite_population

    return @report
  end

end

