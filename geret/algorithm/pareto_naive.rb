
require 'algorithm/algorithm_base'
require 'algorithm/population_archive'
require 'algorithm/phenotypic_truncation'

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
  include PopulationArchiveSupport
  include PhenotypicTruncation 
  
  attr_accessor :init_size, :mutation_probability, :max_archive_size 

  def setup config
    super
  
    raise "ParetoNaive: init_size >= population_size" if @init_size >= @population_size

    @tourney = @cfg.factory( 'tourney' )

    prepare_archive_and_population

    @report.next    
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
      pipe = Util.permutate parents if pipe.size < 2

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
    @archive = phenotypic_truncation( Pareto.nondominated( new_population ), @max_archive_size )

    # reporting
    @report.report @archive
 
    return @report 
  end

end

