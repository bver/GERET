
require 'algorithm/algorithm_base'

class ParetoElitist < AlgorithmBase
 
  attr_accessor :init_size, :mutation_probability

  def setup config
    super
  
    raise "ParetoElitist: init_size >= population_size" if @init_size >= @population_size

    @tourney = @cfg.factory( 'tourney' )

    @population, @elite = @store.load
    @population = [] if @population.nil?
    @elite = {} if @elite.nil?

    @report << "loaded #{@population.size} population individuals"   
    @report << "creating #{@population_size - @population.size} population individuals"
    init_population( @population, @population_size )
    @report << "loaded #{@elite.size} elite individuals"

    @report.next    
    return @report 
  end

  def step
    @report.next    
    @report << "--------- step #{@steps += 1}" 
   
    # parents come from elite and previous population:
    parents = []
    parents.concat @tourney.select_front( @population ) while parents.size < @population_size
    parents.concat @elite.values  
    
    # exploration part of the population
    new_population = []
    init_population( new_population, @init_size )
    
    # exploitation part
    pipe = []
    while new_population.size < @population_size
      pipe = Utils.permutate parents if pipe.size < 2

      chromozome1, chromozome2 = @crossover.crossover( pipe.shift.genotype, pipe.shift.genotype ) 
      chromozome1 = @mutation.mutation chromozome1 if rand < @mutation_probability 
        
      new_individual = @cfg.factory( 'individual', @mapper, chromozome1 ) 
      new_population << new_individual if new_individual.valid?
      new_individual = @cfg.factory( 'individual', @mapper, chromozome2 ) 
      new_population << new_individual if new_individual.valid?
    end

    # next generation
    @population = new_population

    # update elite
    new_population.concat @elite.values
    @elite = {}
    ParetoTourney.front( new_population ).each do |individual|
      individual.shorten_chromozome = true
      @elite[ individual.genotype ] = individual
    end

    # reporting
    @report.report @elite.values
 
    return @report 
  end

  def teardown
    @report << "--------- finished:"
    @store.save [ @population, @elite ]
    return @report   
  end

end

