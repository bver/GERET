
module BreedIndividual 
  
  attr_accessor :inject

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

  protected

  def breed_individual selection 
    parent1 = selection.select_one

    if rand < @probabilities['crossover'] 
      parent2 = selection.select_one
      chromozome, dummy = @crossover.crossover( parent1.genotype, parent2.genotype, parent1.track_support, parent2.track_support ) 
      @cross += 1
    else
      if rand < @probabilities['injection']
        chromozome = init_chromozome @inject
        @injections += 1
      else
        chromozome = parent1.genotype # copy
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

