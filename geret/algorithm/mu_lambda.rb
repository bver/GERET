
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
    init_elitism @population_size
    @report.next    
    return @report    
  end

  def step
    @report.next    
    @report << "--------- step #{@steps += 1}" 
    @report.report @population

    @cross, @injections, @mutate, @copies = 0, 0, 0, 0

    round_robin = RoundRobin.new Utils.permutate( @population )

    lambda_population = []
    elite_population = elite @population

    while lambda_population.size < @lambda_size
      individual = breed_individual round_robin
      lambda_population << individual if individual.valid?
    end

    lambda_population.concat @population if @comma_or_plus == 'plus'

    @population = @selection.select( @population_size - elite_population.size, lambda_population )
    @population.concat elite_population

    @report['numof_crossovers'] << @cross   
    @report['numof_injections'] << @injections
    @report['numof_copies'] << @copies
    @report['numof_mutations'] << @mutate

    return @report
  end

end

