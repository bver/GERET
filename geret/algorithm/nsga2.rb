
require 'algorithm/support/algorithm_base'
require 'algorithm/support/phenotypic_truncation'
require 'algorithm/support/breed'


class Nsga2Individual < Struct.new( :orig, :depth, :crowding, :uniq )
  @@uniq = {}
  @@uniq.default = 0

  def Nsga2Individual.uniq_clear 
    @@uniq.clear
  end

  def initialize( orig, depth, crowding ) 
    super
    @@uniq[orig.genotype] += 1
  end

  def cache_uniq
    self.uniq = @@uniq[orig.genotype]
  end

  def dominates? other
    return true if self.depth < other.depth
    return false if self.depth > other.depth
    return true if self.crowding > other.crowding
    return false if self.crowding < other.crowding   
    return self.uniq < other.uniq
  end
  
  def <=>(other)
    if dominates? other
      return -1
    else
      return 1 if other.dominates? self
      return 0
    end
  end
 
end

class Nsga2BinaryTournament
  include SelectMore

  attr_accessor :population

  def select_one population=self.population
    @population = population
    select_one_internal      
  end

  protected

  def select_one_internal
    begin
      candidate1 = @population[ rand(population.size) ] 
      candidate2 = @population[ rand(population.size) ]  
    end while !candidate1.dominates?( candidate2 ) and !candidate2.dominates?( candidate1 )     
    return candidate1.dominates?( candidate2 ) ? candidate1.orig : candidate2.orig
  end
end

class Nsga2 < AlgorithmBase
  
  include Breed
  include PhenotypicTruncation

  def setup config
    super

    @selection = Nsga2BinaryTournament.new

    @dom_sort = Dominance.new
    @dom_sort.at_least = @population_size

    @population = load_or_init( @store, @population_size )

    @report.next    
    return @report 
  end

  attr_accessor :inject, :shorten_individual 

  def step
    @report.next    
    @report << "--------- step #{@steps += 1}"

    depth = 0
    parent_population = []
    front_report = []
    Nsga2Individual.uniq_clear
    @dom_sort.layers( @population ).each do |layer|
      front = Crowding.distance( layer ) { |orig, cdist| Nsga2Individual.new( orig, depth, cdist ) }
      front.each { |individual| individual.cache_uniq }     
      depth += 1
      empty_slots = @population_size - parent_population.size
      front_report << front.size
      if empty_slots >= front.size 
        parent_population.concat front
      else
        front.sort! # { |a,b| b.crowding <=> a.crowding }
        parent_population.concat front[0...empty_slots]
      end
    end

    @report['fronts_sizes'] << front_report.inspect

    @population = parent_population.map do |individual| 
      individual.orig.shorten_chromozome = @shorten_individual
      individual.orig
    end
    
    @report.report @population # reporting
    
    @selection.population = parent_population

    new_populaton = breed_by_selector( @selection, @population_size )
    @population.concat new_populaton

    @population = phenotypic_truncation( @population, 0 )
    @report['phenotypic_truncation'] << @population.size

    return @report
  end

end
 
