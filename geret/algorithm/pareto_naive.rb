
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
  
  attr_accessor :init_size, :mutation_probability, :max_archive_size, :keep_extremes 

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
    population_part = archive_part = current_size = 0
    #ratio = (@archive.size / @tourney.tournament_size).to_i
    ratio = @archive.empty? ? 1 : @archive.size
    @report['part_ratio'] << ratio
    while parents.size < @population_size
      ratio.times do
        parents.concat @tourney.select_front( @population ) 
        population_part += ( parents.size - current_size )
        current_size = parents.size
      end
      
      parents.concat @archive
      archive_part += ( parents.size - current_size )    
      current_size = parents.size
    end
    @report['part_population'] << population_part
    @report['part_archive'] << archive_part

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
    @population = new_population.clone

    # update archive
    new_population.concat @archive
    @archive = Pareto.nondominated( phenotypic_truncation( new_population, @max_archive_size ) )

    # keep population extremes
    if @keep_extremes
      new_population.first.objective_symbols.each do |obj|
        best = Pareto.objective_best( new_population, new_population.first.class, obj )
        @archive.push best
        @report['pop_best_' + obj.to_s] << best.send(obj)
      end
    end

    # reporting
    @report.report @archive
 
    return @report 
  end

end

