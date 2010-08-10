
require 'algorithm/support/algorithm_base'
require 'algorithm/support/phenotypic_truncation'


class AlpsStrict < AlgorithmBase
  include PhenotypicTruncation
  
  attr_accessor :max_layers, :elite_size, :aging_scheme, :age_gap, :layer_diagnostic

  def setup config
    super
     
    @layer_size = @population_size.divmod( @max_layers ).first   

    AlpsIndividual.age_gap @age_gap
    AlpsIndividual.aging_scheme @aging_scheme
    AlpsIndividual.layers @max_layers
    @report['age_limits'] << AlpsIndividual.age_limits

    @layers = []
    
    @dominance = Dominance.new
    @population = []

    @report.next    
    return @report    
  end

 
  def step
    @report << "--------- step #{@steps}"
    
    if @steps.divmod(@age_gap).last == 0

      if AlpsIndividual.age_limits.include? @steps
        @report << "--------- opening a new layer, layer[0] unshift"              
        @layers.unshift init_population( [], @layer_size ) 
      else
        @report << "--------- (re)starting population layer[0]"       
        @layers[0] = init_population( [], @layer_size ) 
      end

      @steps += 1   
      @report.next 
      return @report   
     
    end

    @population = @layers.flatten
    @report.report @population

    new_layers = []
    mig_counts = []
    nonpde_counts = []
    @layers.each_with_index do |unsorted,index|

      # migrations
      migrations = []
      prev_layer = []
      if index > 0
        @layers[index-1].each do |individual|
          if individual.layer < index
            prev_layer << individual
          else
            migrations << individual
          end
        end
        @layers[index-1] = prev_layer # set back, still sorted (hopefully)
      end
      mig_counts << migrations.size
      
      # sort the layer by pareto strength     
      layer1 = @dominance.rank_count( unsorted+migrations ).sort {|a,b| a.spea <=> b.spea }

      # extract individuals from dominance's shell     
      layer1.map! { |fields| fields.original } 
      
      # truncate the size, drop loosers
      layer1 = layer1.slice( 0 ... @layer_size )
      
      # elitism
      new_layer = layer1.slice( 0 ... @elite_size ).map do |individual|
        copy = individual.clone
        copy.parents individual   # increment age
        copy
      end
          
      # breed
      layer2 = (index > 0) ? @layers[index-1] : layer1               
      layer2 = layer1 if layer2.empty?
      addon = breed( layer1, layer2, @layer_size-new_layer.size )
      new_layer.concat addon
      
      # eliminate phenotypic duplicities
      pde = eliminate_duplicates new_layer 
      
      # add the rest
      new_layer = breed( layer1, layer2, @layer_size-pde.size )
      nonpde_counts << new_layer.size     
      new_layer.concat pde

      # result
      new_layers << new_layer

      # set back sorted
      @layers[index] = layer1
    end

    @layers = new_layers

    # layer diagnostic
    @report['layer_sizes'] << @layers.map { |layer| layer.size }
    @report['migration_sizes'] << mig_counts
    @report['nonpde_counts'] << nonpde_counts   
    @layers.each_with_index do |layer,index| 
      layer.first.objective_symbols.each do |objective|     
        values = layer.map { |individual| individual.send(objective) }   
        min, max, avg, n = Util.statistics values  
        @report["layer_#{index}_#{objective}"] << "min: #{min} max: #{max} avg: #{avg} n: #{n}"
      end
    end if @layer_diagnostic
    
    @report['numof_evaluations'] << @evaluator.jobs_processed if defined? @evaluator   
   
    @steps += 1   
    @report.next 
    return @report   
  end

  protected

  def tournament layer 
    # works only on sorted data
    i1 = rand(layer.size)
    i2 = rand(layer.size)         
    layer[ i1 < i2 ? i1 : i2 ]
  end

  def breed( layer1, layer2, children_size ) 

    children = []
    
    while children.size < children_size
     
      parent1 = tournament( rand < 0.5 ? layer1 : layer2 )
      #parent1 = tournament(layer1)

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

