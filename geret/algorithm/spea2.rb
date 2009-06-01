
require 'algorithm/algorithm_base'
require 'algorithm/breed_individual'
require 'algorithm/population_archive'

class Spea2Ranking < Ranking 
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

  def environmental_selection best_size
    @ranked_pop.sort! {|a,b| a.spea <=> b.spea }         
    @ranked_pop[ 0...best_size ].map { |individual| individual.original }
  end
end

class Spea2 < AlgorithmBase
  include BreedIndividual
  include PopulationArchiveSupport
  
  attr_accessor :archive_size

  def setup config
    super
  
    @ranker = @selection.ranker
    
    prepare_archive_and_population
    
    @report.next    
    return @report 
  end
 
  def step
    @report.next    
    @report << "--------- step #{@steps += 1}"

    combined = @population
    combined.concat @archive
    @ranker.population = combined

    @archive = @ranker.environmental_selection @archive_size
    @selection.population = @archive

    @cross, @injections, @mutate, @copies = 0, 0, 0, 0
    @population = []
    while @population.size < @population_size
      individual = breed_individual @selection 
      @population << individual if individual.valid?
    end
  
    @report['numof_crossovers'] << @cross   
    @report['numof_injections'] << @injections
    @report['numof_copies'] << @copies
    @report['numof_mutations'] << @mutate
  
    @report.report @archive
    return @report
  end

end

