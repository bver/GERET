
require 'algorithm/algorithm_base'

class SingleObjective < AlgorithmBase
  
  attr_accessor :inject, :probabilities

  def setup config
    super
    @selection = @cfg['selection_rank'].nil? ? 
                 @cfg.factory('selection') : 
                 @cfg.factory('selection', @cfg.factory('selection_rank') ) 

    @population = @store.load
    @population = [] if @population.nil?
    @report << "loaded #{@population.size} individuals"   
    @report << "creating #{@population_size - @population.size} individuals"
    init_population( @population, @population_size )

    return @report 
  end

  def teardown
    @report << "--------- finished:"
    @store.save @population
    return @report   
  end

  protected

  def breed_individual selection 
    if rand < @probabilities['crossover'] 
      parents = selection.select 2 
      chromozome, dummy = @crossover.crossover( parents.first.genotype, parents.last.genotype ) 
      @cross += 1
    else
      if rand < @probabilities['injection']
        chromozome = init_chromozome @inject
        @injections += 1
      else
        chromozome = selection.select_one.genotype 
        @copies +=1
      end
    end
   
    if rand < @probabilities['mutation']
      chromozome = @mutation.mutation chromozome   
      @mutate += 1
    end
      
    return @cfg.factory( 'individual', @mapper, chromozome ) 
  end
  
end

