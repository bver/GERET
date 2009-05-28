
require 'algorithm/algorithm_base'

class Nsga2Individual < Struct.new( :orig, :depth, :crowding )
  @@uniq = {}
  @@uniq.default = 0

  def Nsga2Individual.uniq_clear 
    @@uniq.clear
  end

  def initialize( orig, depth, crowding ) 
    super
    @@uniq[orig.phenotype] += 1
  end

  def uniq
    @@uniq[orig.phenotype]
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

class Nsga2 < AlgorithmBase

  def setup config
    super

    @population = @store.load
    @population = [] if @population.nil?
    @report << "loaded #{@population.size} individuals"   
    @report << "creating #{@population_size - @population.size} individuals"
    init_population( @population, @population_size )

    @dom_sort = Dominance.new
    @dom_sort.at_least = @population_size
  
    @report.next    
    return @report 
  end

  attr_accessor :inject

  def step
    @report.next    
    @report << "--------- step #{@steps += 1}"

    depth = 0
    parent_population = []
    front_report = []
    Nsga2Individual.uniq_clear
    @dom_sort.layers( @population ).each do |layer|
      front = Crowding.distance( layer ) { |orig, cdist| Nsga2Individual.new( orig, depth, cdist ) }
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

    @population = parent_population.map { |individual| individual.orig }
    
    @report.report @population # reporting
    
    cross = injections = copies = mutate = 0
    while @population.size < @population_size * 2
      parent1 = binary_tournament parent_population

      if rand < @probabilities['crossover']
        parent2 = binary_tournament parent_population

        chromozome, chromozome2 = @crossover.crossover( parent1.orig.genotype, parent2.orig.genotype )       
        individual = @cfg.factory( 'individual', @mapper, chromozome2 ) 
        @population << individual if individual.valid?

        cross += 1
      else
        if rand < @probabilities['injection']
          chromozome = init_chromozome @inject       
          injections += 1
        else 
          chromozome = parent1.orig.genotype.clone
          copies += 1
        end
      end

      if rand < @probabilities['mutation'] 
        chromozome = @mutation.mutation chromozome      
        mutate +=1
      end

      individual = @cfg.factory( 'individual', @mapper, chromozome )
      @population << individual if individual.valid?

    end

    @report['numof_crossovers'] << cross   
    @report['numof_injections'] << injections
    @report['numof_copies'] << copies
    @report['numof_mutations'] << mutate

    return @report
  end

  protected 

  def binary_tournament population
    begin
      candidate1 = population[ rand(population.size) ] 
      candidate2 = population[ rand(population.size) ]
    end while !candidate1.dominates?( candidate2 ) and !candidate2.dominates?( candidate1 )     

    return candidate1.dominates?( candidate2 ) ? candidate1 : candidate2
  end

end
 
