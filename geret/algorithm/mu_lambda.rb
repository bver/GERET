
require 'algorithm/single_objective'

class MuLambda < SingleObjective
 
  attr_accessor :comma_or_plus, :lambda_size

  def setup config
    super
    raise "MuLambda: lambda_size < population_size" if @comma_or_plus == 'lambda' and @lambda_size < @population_size

    return @report    
  end

  def step
    @report << "--------- step #{@steps += 1}" 

    @cross, @injections, @mutate, @copies = 0, 0, 0, 0

    round_robin = RoundRobin.new( Utils.permutate @population )
    lambda_population.concat @population if @comma_or_plus == 'plus'

    while lambda_population.size < @lambda_size
      individual = breed_individual round_robin
      lambda_population << individual if individual.valid?
    end
    
    @population = @selection.select( @population_size, lambda_population )

    @report['numof_crossovers'] << @cross   
    @report['numof_injections'] << @injections
    @report['numof_copies'] << @copies
    @report['numof_mutations'] << @mutate

    @report.next   
    return @report
  end

end

