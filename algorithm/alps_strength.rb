
require 'algorithm/support/algorithm_base'
require 'algorithm/support/phenotypic_truncation'


class AlpsStrength < AlgorithmBase
  include PhenotypicTruncation
  
  attr_accessor :max_layers, :elite_size, :aging_scheme, :age_gap, :layer_diagnostic

  def setup config
    super
     
    @layer_size = @population_size.divmod( @max_layers ).first   

    AlpsIndividual.age_gap @age_gap
    AlpsIndividual.aging_scheme @aging_scheme
    AlpsIndividual.layers @max_layers
    @report['age_limits'] << AlpsIndividual.age_limits

    @population = load_or_init( @store, @layer_size )
    
#    evaluate_population @population

    @dominance = Dominance.new

    @report.next    
    return @report    
  end

 
  def step
    @report.next 
    @report << "--------- step #{@steps += 1}"
    @report.report @population

    # then clasify individuals into layers
    all_layers = []
    @population.each do |individual|
      index = individual.layer
      all_layers << [] while index >= all_layers.size
      all_layers[index] << individual 
    end

    # discard empty layers
    all_layers.delete_if { |layer| layer.empty? }

    all_layers.map! do |layer|
      # eliminate phenotypic duplicities
      pde = eliminate_duplicates layer 

      # sort each layer by pareto strength     
      sorted = @dominance.rank_count( pde ).sort {|a,b| a.spea <=> b.spea }

      # extract individuals from dominance's shell     
      sorted.map! { |fields| fields.original } 

      # truncate the size, drop loosers
      sorted.slice( 0 ... @layer_size )
    end

    # layer diagnostic
    @report['layer_sizes'] << all_layers.map { |layer| layer.size }
    
    all_layers.each_with_index do |layer,index| 
      layer.first.objective_symbols.each do |objective|     
        values = layer.map { |individual| individual.send(objective) }   
        min, max, avg, n = Util.statistics values  
        @report["layer_#{index}_#{objective}"] << "min: #{min} max: #{max} avg: #{avg} n: #{n}"
      end
    end if @layer_diagnostic
   
    # construct new population
    @population = []
    all_layers.each_with_index do |layer1,index|
      
      layer2 = index > 0 ? all_layers[index-1] : layer1

      if index == 0 and @steps.divmod( @age_gap+2 ).last == 0
        @report << '------ restarting the first layer (age_gap)'
        @population.concat init_population( [], @layer_size ) 
      else
        @population.concat breed( layer1, layer2 )
      end

      # elitism, sort of     
      elite = layer1.slice( 0 ... @elite_size ) 
      elite.each { |individual| individual.parents individual } # increment age
      @population.concat elite

    end

    @report['numof_evaluations'] << @evaluator.jobs_processed if defined? @evaluator   
   
    return @report   
  end

  protected

  def tournament layer 
    # works only on sorted data
    i1 = rand(layer.size)
    i2 = rand(layer.size)         
    layer[ i1 < i2 ? i1 : i2 ]
  end

  def breed( layer1, layer2 ) 

    children = []

    while children.size < @layer_size
      #parent1 = tournament( rand < 0.5 ? layer1 : layer2 )
      parent1 = tournament(layer1)

      if rand < @probabilities['crossover']

        parent2 = tournament( rand < 0.5 ? layer1 : layer2 )

        child1, child2 = @crossover.crossover( 
                              parent1.genotype, parent2.genotype, 
                              parent1.track_support, parent2.track_support ) 

        individual = @cfg.factory( 'individual', @mapper, child1 ) 
        individual.parents( parent1, parent2 )
        children << individual if individual.valid? 

        individual = @cfg.factory( 'individual', @mapper, child2 ) 
        individual.parents( parent1, parent2 )       
        children << individual if individual.valid? 
 
      end

      if rand < @probabilities['mutation']

        child = @mutation.mutation( parent1.genotype, parent1.track_support )
  
        individual = @cfg.factory( 'individual', @mapper, child ) 
        individual.parents( parent1 )         
        children << individual if individual.valid? 
        
      end

    end

    @evaluator.run children if defined? @evaluator 
    children
  end 
end

