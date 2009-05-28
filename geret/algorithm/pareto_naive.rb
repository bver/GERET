
require 'algorithm/algorithm_base'

class CroppingIndividual < Struct.new( :orig, :uniq )
  @@uniq = {}
  @@uniq.default = 0

  def CroppingIndividual.uniq_clear 
    @@uniq.clear
  end

  def initialize( orig ) 
    super
    @@uniq[orig.phenotype] += 1
  end

  def cache_uniq
    self.uniq = @@uniq[orig.phenotype]
  end
 
  def <=>(other)
    if self.uniq < other.uniq
      return -1
    else
      return 1 if other.uniq < self.uniq
      return 0
    end
  end
end

class ParetoNaive < AlgorithmBase
 
  attr_accessor :init_size, :mutation_probability, :max_archive_size

  def setup config
    super
  
    raise "ParetoNaive: init_size >= population_size" if @init_size >= @population_size

    @tourney = @cfg.factory( 'tourney' )

    @archive, @population = @store.load
    @archive = [] if @archive.nil?
    @population = [] if @population.nil?

    @report << "loaded #{@population.size} population individuals"   
    @report << "creating #{@population_size - @population.size} population individuals"
    init_population( @population, @population_size )
    @report << "loaded #{@archive.size} archive individuals"

    @report.next    
    return @report 
  end

  def teardown
    @report << "--------- finished:"
    @store.save [@archive, @population]
    return @report   
  end
  
  def step
    @report.next    
    @report << "--------- step #{@steps += 1}" 
   
    # parents come from the archive and the previous population:
    parents = []
    parents.concat @tourney.select_front( @population ) while parents.size < @population_size
    parents.concat @archive  
    
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

    # update archive
    new_population.concat @archive
    CroppingIndividual.uniq_clear 
    cropping = ParetoTourney.front( new_population ).map { |individual| CroppingIndividual.new( individual ) }
    cropping.each { |crop| crop.cache_uniq }
    @archive = cropping.sort[ 0...@max_archive_size ].map { |crop| crop.orig }

    # reporting
    @report.report @archive
 
    return @report 
  end

end

