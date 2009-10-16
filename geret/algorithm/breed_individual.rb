
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
   
    individual = @cfg.factory( 'individual', @mapper, chromozome )    
    if individual.valid? and rand < @probabilities['mutation']
      chromozome = @mutation.mutation( chromozome, individual.track_support )
      individual = @cfg.factory( 'individual', @mapper, chromozome )
      @mutate += 1
    end
      
    return individual
  end

  def breed_population( parent_population, required_size )
    robin = RoundRobin.new parent_population
    breed_by_selector( robin, required_size )
  end

  def breed_by_selector( selector, required_size )

    children = []
    @cross, @injections, @mutate = 0, 0, 0, 0

    while children.size < required_size
      if rand < @probabilities['crossover']  
        parent1, parent2 = selector.select 2
        child1, child2 = @crossover.crossover( parent1.genotype, parent2.genotype, 
                                               parent1.track_support, parent2.track_support ) 

        individual = @cfg.factory( 'individual', @mapper, child1 )
        children << individual if individual.valid? 
  
        individual = @cfg.factory( 'individual', @mapper, child2 )
        children << individual if individual.valid? 

        @cross += 1       
      end

      if rand < @probabilities['mutation']
        parent = selector.select_one
        child = @mutation.mutation( parent.genotype, parent.track_support )
  
        individual = @cfg.factory( 'individual', @mapper, child )
        children << individual if individual.valid? 
        
        @mutate += 1
      end

      if rand < @probabilities['injection']
        child1 = init_chromozome @inject
  
        individual = @cfg.factory( 'individual', @mapper, child1 )
        children << individual if individual.valid? 

        @injections += 1
      end

    end
    children = children[ 0...required_size ]

    @evaluator.run children if defined? @evaluator
 
    children
  end

end

