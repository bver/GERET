
require 'algorithm/algorithm_base'

class CroppingIndividual < Struct.new( :orig )
  @@uniq = {}
  @@uniq.default = []

  def CroppingIndividual.uniq_clear 
    @@uniq.clear
  end

  def initialize( orig ) 
    super
    @@uniq[orig.phenotype] << orig
  end

  def CroppingIndividual.slim max_size
    current_size = @@uniq.values.flatten.size
    while current_size > max_size 
      candidate = @@uniq.values.max {|a,b| a.size <=> b.size }
      return @@uniq.values.flatten if candidate.size == 1
      candidate.pop
      current_size -= 1
    end
    @@uniq.values.flatten
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
    while parents.size < @population_size
      parents.concat @tourney.select_front( @population ) 
      parents.concat @archive
    end
    
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
    uniq = {}
    ParetoTourney.front( new_population ).map do |individual| 
      slot = uniq.fetch( individual.phenotype, [] ) 
      slot.push individual
      uniq[individual.phenotype] = slot
    end

    # trim archive size, decimate duplicate phenotypes first
    current_size = uniq.values.flatten.size
    @report['size_before_truncation'] << current_size
    while current_size > @max_archive_size 
      candidate = uniq.values.max {|a,b| a.size <=> b.size }
      break if candidate.size == 1
      candidate.pop
      current_size -= 1
    end
    @archive = uniq.values.flatten

    # reporting
    @report.report @archive
 
    return @report 
  end

end

