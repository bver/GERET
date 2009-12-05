
module Breed
  
  attr_accessor :inject

  protected

  def breed_individual selector
    children = []
    breed_few( selector, children ) while children.empty?
 
    individual = children[ rand( children.size ) ]
    @evaluator.run [individual] if defined? @evaluator

    individual
  end

  def breed_few( selector, children )

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

  def breed_population( parent_population, required_size )
    robin = RoundRobin.new parent_population
    breed_by_selector( robin, required_size )
  end

  def breed_by_selector( selector, required_size )

    children = []
    @cross, @injections, @mutate = 0, 0, 0, 0

    breed_few( selector, children ) while children.size < required_size
    children = children[ 0...required_size ]

    @evaluator.run children if defined? @evaluator
 
    @report['numof_crossovers'] << @cross   
    @report['numof_injections'] << @injections
    @report['numof_mutations'] << @mutate
   
    children
  end

end

