
require 'algorithm/algorithm_base'
require 'algorithm/phenotypic_truncation'

class ParetoGPSimplified < AlgorithmBase
  include PhenotypicTruncation

  attr_accessor :archive_size, :generations_per_cascade, :mutation_probability, :tournament_size 

  def setup config
    super

    @population_tourney = ParetoTourney.new 
    @population_tourney.tournament_size = @tournament_size

    @population = []

    @archive = load_or_init( @store, @archive_size )
   
    @steps = 0
    @generation = 0
    return @report       
  end
  
  def teardown
    @report << "--------- finished:"
    @store.save @archive
    return @report   
  end

  def step
    @report.next       
    @report << "--------- step #{@steps += 1}, generation #{@generation}" 

     # init population   
    if @generation == 0
      @report << "initializing population"  
      @population = []
      init_population( @population, @population_size )   
    end

    # create a new population from the current one
    population_pipe = []
    archive_pipe = []
    new_population = [] 
    while new_population.size < @population_size

      population_pipe = @population_tourney.select_front @population while population_pipe.empty?
      archive_pipe = Util.permutate @archive while archive_pipe.empty?

      parent1, parent2 = [ population_pipe.shift, archive_pipe.shift ]
      chromozome1, chromozome2 = @crossover.crossover( parent1.genotype, parent2.genotype, parent1.track_support, parent2.track_support )     

      individual = @cfg.factory( 'individual', @mapper, chromozome1 )
      if individual.valid? and rand < @mutation_probability      
        chromozome1 = @mutation.mutation( chromozome1, individual.track_support )
        individual = @cfg.factory( 'individual', @mapper, chromozome1 ) 
      end
        
      new_population << individual if individual.valid?

      individual = @cfg.factory( 'individual', @mapper, chromozome2 ) 
      new_population << individual if individual.valid?
       
    end

    @evaluator.run new_population if defined? @evaluator

    @population = new_population
 
    # keep population extremes
    @population.first.objective_symbols.each do |obj|
      best = Pareto.objective_best( @population, @population.first.class, obj )
      @archive.push best
      @report['pop_best_' + obj.to_s] << best.send(obj)
    end

    if @generation == @generations_per_cascade 

      # archive merging     
      @archive = phenotypic_truncation( Pareto.nondominated( @archive ), @archive_size )

      @report.report @archive      
      @generation = 0
    else
      @generation += 1
    end # consolidation

    return @report 
  end

end

