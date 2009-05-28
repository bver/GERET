
require 'algorithm/algorithm_base'

class ParetoGPSimplified < AlgorithmBase
 
  attr_accessor :archive_size, :generations_per_cascade, :mutation_probability, :shorten_archive_individual 

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
      sorted = Pareto.objective_sort( @population, @population.first.class, obj )
      @archive.push sorted.first
      @report['pop_best_' + obj.to_s] << sorted.first.send(obj)
    end

    if @generation == @generations_per_cascade 

     # archive merging     
      uniq = {}
      @archive.concat @population
      ParetoTourney.front( @archive ).map do |individual|
        individual.shorten_chromozome = @shorten_archive_individual
        slot = uniq.fetch( individual.phenotype, [] ) 
        slot.push individual
        uniq[individual.phenotype] = slot
      end

      # trim archive size, decimate duplicate phenotypes first
      current_size = uniq.values.flatten.size
      @report['size_before_truncation'] << current_size
      while current_size > @archive_size 
        candidate = uniq.values.max {|a,b| a.size <=> b.size }
        break if candidate.size == 1
        candidate.pop
        current_size -= 1
      end
      @archive = uniq.values.flatten

      @report.report @archive      
      @generation = 0
    else
      @generation += 1
    end # consolidation

    return @report 
  end

end

