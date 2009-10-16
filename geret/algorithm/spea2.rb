
require 'algorithm/algorithm_base'
require 'algorithm/breed_individual'
require 'algorithm/population_archive'
require 'algorithm/phenotypic_truncation'

class Spea2Ranking < Ranking 
  include PhenotypicTruncation

  def initialize
    @dominance = Dominance.new
    @reranker = Ranking.new( :spea, :minimize )
  end

  def population= pop
    @ranked_pop = @dominance.rank_count pop
  end

  def rank selected
    rank_selection = selected.map { |orig| @ranked_pop.find { |r| r.original == orig } }
    reranked = @reranker.rank( rank_selection )   
    reranked.each { |field| field.original = field.original.original } 
    reranked
  end

  def environmental_selection max_size
    valid_population = @ranked_pop.find_all { |individual| individual.original.valid? }
    valid_population.sort! {|a,b| a.spea <=> b.spea } 
    limited_population = valid_population[ 0...max_size ].map { |individual| individual.original }
    phenotypic_truncation( limited_population, 0 )   
  end
end

class Spea2 < AlgorithmBase
  include BreedIndividual
  include PopulationArchiveSupport
  
  attr_accessor :max_archive_size, :shorten_archive_individual 

  def setup config
    super
  
    @ranker = @selection.ranker
    @ranker.shorten_individual = @shorten_archive_individual 
    
    prepare_archive_and_population
    
    @report.next    
    return @report 
  end
 
  def step
    @report.next    
    @report << "--------- step #{@steps += 1}"

    combined = @population.clone
    combined.concat @archive
    @ranker.population = combined

    @archive = @ranker.environmental_selection @max_archive_size

    @selection.population = @archive
   
    @population = breed_by_selector( @selection, @population_size )
 
    @report['numof_crossovers'] << @cross   
    @report['numof_injections'] << @injections
    @report['numof_copies'] << @copies
    @report['numof_mutations'] << @mutate
  
    @report.report @archive
    return @report
  end

end

