
require 'algorithm/support/algorithm_base'
require 'algorithm/support/breed'
require 'algorithm/support/phenotypic_truncation'

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
  include Breed
  include PhenotypicTruncation

  attr_accessor :max_archive_size, :shorten_archive_individual 

  def setup config
    super
  
    @ranker = @selection.ranker
    @ranker.shorten_individual = @shorten_archive_individual 
    
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

    combined = @population.clone
    combined.concat @archive
    @ranker.population = combined

    @archive = @ranker.environmental_selection @max_archive_size

     
    if @duplicate_elimination
      @cross, @injections, @mutate = 0, 0, 0  
      sizes = []

      @population = []
      while @population.size < @population_size
        @selection.population = @archive.clone
        new_populaton = breed_by_selector_no_report( @selection, @population_size )
        @population.concat new_populaton
        @population = eliminate_duplicates @population
        sizes << @population.size
      end

      @report['eliminated_sizes'] << sizes
      @report['numof_crossovers'] << @cross   
      @report['numof_injections'] << @injections
      @report['numof_mutations'] << @mutate
      @report['time_eval'] << @time_eval        
      @report['numof_evaluations'] << @evaluator.jobs_processed if defined? @evaluator

    else
      @selection.population = @archive
      @population = breed_by_selector( @selection, @population_size )  
    end
   
    @report.report @archive
    return @report
  end

end

