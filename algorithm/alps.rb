
require 'algorithm/support/algorithm_base'
require 'algorithm/support/elitism'
require 'algorithm/support/phenotypic_truncation'

class AlpsInd < PipedIndividual
  include AlpsIndividual
end

class Alps < AlgorithmBase
  include Elitism
  include PhenotypicTruncation

  attr_accessor :max_layers, :aging_scheme, :age_gap, :layer_diagnostic 

  def setup config
    super
     
    @max_layer_size = @population_size.divmod( @max_layers ).first   

    AlpsIndividual.age_gap @age_gap
    AlpsIndividual.aging_scheme @aging_scheme
    AlpsIndividual.layers @max_layers
    @report['age_limits'] << AlpsIndividual.age_limits.inspect

    @population = load_or_init( @store, @max_layer_size )

    init_elitism @max_layer_size
    
    evaluate_population

    @report.next    
    return @report    
  end

  def step

    @report.next 
    @report << "--------- step #{@steps += 1}"
    @report.report @population

    # sort @population's individuals into all_layers
    all_layers = []
    @population.each do |individual|
      index = individual.layer
      all_layers << [] while index >= all_layers.size
      all_layers[index] << individual 
    end

    # restart junior population each @age_gap   
    if @steps.divmod( @age_gap+2 ).last == 0
      @report << '------ restarting the first layer (age_gap)'
      all_layers[0] = init_population( [], @max_layer_size ) 
    end

    # discard empty layers
    all_layers.delete_if { |layer| layer.empty? }

    # phenotype duplicate elimination
    @report['layer_sizes'] << (all_layers.map { |layer| layer.size }).inspect
    if @duplicate_elimination
      all_layers.map! { |layer| eliminate_duplicates layer }
      @report['layer_sizes_pde'] << (all_layers.map { |layer| layer.size }).inspect    
    end

    # layer diagnostic
    all_layers.each_with_index do |layer,index| 
      layer.first.objective_symbols.each do |objective|     
        values = layer.map { |individual| individual.send(objective) }   
        min, max, avg, n = Util.statistics values  
        @report["layer_#{index}_#{objective}"] << "min: #{min} max: #{max} avg: #{avg} n: #{n}"
      end
    end if @layer_diagnostic

    # breed @population from adjacent all_layers
    @population = [] 
    all_layers.each_with_index do |layer,index|
      parents = layer.clone
      parents.concat all_layers[index-1] if index > 0
      @population.concat breed( parents )
      @population.concat cream( layer )
    end
   
    evaluate_population

    return @report
  end

  protected

  def evaluate_population 
    t1 = Time.now
    @evaluator.run @population if defined? @evaluator
    @time_eval += (Time.now - t1)   
    @report['time_eval'] << @time_eval        
    @report['numof_evaluations'] << @evaluator.jobs_processed if defined? @evaluator
  end

  def cream( parents )
    elite( parents ).map do |individual| 
      copy = @cfg.factory( 'individual', @mapper, individual.genotype )
      copy.parents individual
      copy
    end
  end

  def breed( parents )

    @selection.population = parents

    children = []
    while children.size < @max_layer_size

      if rand < @probabilities['crossover']  
        parent1, parent2 = @selection.select 2
        child1, child2 = @crossover.crossover( parent1.genotype, parent2.genotype, 
                                               parent1.track_support, parent2.track_support ) 

        individual = @cfg.factory( 'individual', @mapper, child1 ) 
        individual.parents( parent1, parent2 )
        children << individual if individual.valid? 
  
        individual = @cfg.factory( 'individual', @mapper, child2 ) 
        individual.parents( parent1, parent2 )       
        children << individual if individual.valid? 

      end

      if rand < @probabilities['mutation']

        parent = @selection.select_one
        child = @mutation.mutation( parent.genotype, parent.track_support )
  
        individual = @cfg.factory( 'individual', @mapper, child ) 
        individual.parents( parent )         
        children << individual if individual.valid? 
        
      end
     
    end

    children
  end

end

