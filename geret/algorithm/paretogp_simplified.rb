
require 'algorithm/algorithm_base'
require 'algorithm/phenotypic_truncation'

class ParetoGPSimplified < AlgorithmBase
  include PhenotypicTruncation

  attr_accessor :archive_size, :generations_per_cascade, :mutation_probability 

  def setup config
    super

    @archive = @store.load
    @archive = [] if @archive.nil?
    @population = []
    
    @report << "loaded #{@archive.size} archive individuals"
    @report << "creating #{@archive_size - @archive.size} archive individuals"
    init_population( @archive, @archive_size ) 

    @population_tourney = @cfg.factory( 'population_tourney' )

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
      archive_pipe = Utils.permutate @archive while archive_pipe.empty?

      chromozome1, chromozome2 = @crossover.crossover( population_pipe.shift.genotype, archive_pipe.shift.genotype )     

      chromozome1 = @mutation.mutation chromozome1 if rand < @mutation_probability 
        
      individual = @cfg.factory( 'individual', @mapper, chromozome1 ) 
      new_population << individual if individual.valid?
      individual = @cfg.factory( 'individual', @mapper, chromozome2 ) 
      new_population << individual if individual.valid?
       
    end
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

