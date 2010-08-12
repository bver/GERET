
require 'set'
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

      @report << "--------- opening a new layer, layer[0] unshift"              
      @layers.unshift init_population( [], @layer_size ) 

      @steps += 1   
      @report.next 
      return @report   
     
    end

    # reporting
    @population = @layers.flatten
    @report.report @population

    # main breed
    new_layers = []
    parents_counts = []
    @layers.each_with_index do |unsorted, index|
      parents = index > 0 ? unsorted+@layers[index-1] : unsorted 
      new_layers << breed( parents )
      parents_counts << parents.size
    end

    # resort according layer index
    @layers = []
    new_layers.flatten.each do |individual|
      index = individual.layer
      @layers << [] while index >= @layers.size
      @layers[index] << individual 
    end
 
    # discard empty layers
    @layers.delete_if { |layer| layer.empty? }
  

    # layer diagnostic
    @report['new_layers_sizes'] << new_layers.map { |layer| layer.size }
    @report['layer_sizes'] << @layers.map { |layer| layer.size }
    @report['parents_sizes'] << parents_counts
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

  def breed( unsorted ) 

    # sort each layer by pareto strength        
    layer = @dominance.rank_count( unsorted ).sort {|a,b| a.spea <=> b.spea }
      
    # extract individuals from dominance's shell     
    layer.map! { |fields| fields.original } 

    # PDE
    uniq = Set.new

    # elitism
    elite = []
    layer.slice( 0 ... @elite_size ).each do |individual|
      #uniq.add( individual.phenotype )
      next if uniq.add?( individual.phenotype ).nil?
      
      copy = individual.clone
      copy.parents individual   # increment age
      elite << copy
    end

    # xover, mutations
    children = []   
    while children.size + elite.size < @layer_size 
     
      parent1 = tournament(layer)

      if rand < @probabilities['crossover']

        parent2 = tournament(layer)

        child1, child2 = @crossover.crossover( 
                              parent1.genotype, parent2.genotype, 
                              parent1.track_support, parent2.track_support ) 

        individual = @cfg.factory( 'individual', @mapper, child1 ) 
        individual.parents( parent1, parent2 )
        children << individual if individual.valid? and not uniq.add?( individual.phenotype ).nil? 
       

        individual = @cfg.factory( 'individual', @mapper, child2 ) 
        individual.parents( parent1, parent2 )       
        children << individual if individual.valid? and not uniq.add?( individual.phenotype ).nil?        
 
      end

      if rand < @probabilities['mutation']

        child = @mutation.mutation( parent1.genotype, parent1.track_support )
  
        individual = @cfg.factory( 'individual', @mapper, child ) 
        individual.parents( parent1 )         
        children << individual if individual.valid? and not uniq.add?( individual.phenotype ).nil?       
        
      end

    end

    @evaluator.run children if defined? @evaluator 
    elite + children
  end 
end

