
require 'algorithm/algorithm_base'

class Nsga2Individual < Struct.new( :orig, :depth, :crowding )
  def dominates? other
    return true if self.depth < other.depth
    return false if self.depth > other.depth
    return self.crowding > other.crowding
  end
end

class Nsga2 < AlgorithmBase

  def setup config
    super

    initial_pop = @store.load
    initial_pop = [] if initial_pop.nil?
    @report << "loaded #{initial_pop.size} individuals"   
    @report << "creating #{@population_size - initial_pop.size} individuals"
    init_population( initial_pop, @population_size )

    @population = []   
    depth = 0
    @dom_sort = Dominance.new
    @dom_sort.layers( initial_pop ).each do |layer|
      front = Crowding.distance( layer ) { |individual, cdist| Nsga2Individual.new( individual, depth, cdist ) }
      depth += 1
      @population.concat front
    end

    @dom_sort.at_least = @population_size
  
    @report.next    
    return @report 
  end

  attr_accessor :inject

  def step
    @report.next    
    @report << "--------- step #{@steps += 1}"

    combined_population = @population.map { |individual| individual.orig }
    
    @report.report combined_population # reporting
    
    uniq = {}
    cross = injections = copies = mutate = 0
    while uniq.size < @population_size * 2  #combined_population.size < @population_size * 2
      candidate1 = @population[ rand(@population.size) ] 
      candidate2 = @population[ rand(@population.size) ]
      next if !candidate1.dominates?( candidate2 ) and !candidate2.dominates?( candidate1 )     
      parent1 = candidate1.dominates?( candidate2 ) ? candidate1 : candidate2

      if rand < @probabilities['crossover']
        candidate1 = @population[ rand(@population.size) ] 
        candidate2 = @population[ rand(@population.size) ]
        next if !candidate1.dominates?( candidate2 ) and !candidate2.dominates?( candidate1 )    
        parent2 = candidate1.dominates?( candidate2 ) ? candidate1 : candidate2

        chromozome, chromozome2 = @crossover.crossover( parent1.orig.genotype, parent2.orig.genotype )       
        individual = @cfg.factory( 'individual', @mapper, chromozome2 ) #do not waste the 2nd offspring
        #combined_population << individual if individual.valid?
        individual.shorten_chromozome = true
        uniq[ individual.genotype ] = individual if individual.valid?

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
      #combined_population << individual if individual.valid?
      individual.shorten_chromozome = true
      uniq[ individual.genotype ] = individual if individual.valid?

    end
    combined_population.concat uniq.values

    @report['numof_crossovers'] << cross   
    @report['numof_injections'] << injections
    @report['numof_copies'] << copies
    @report['numof_mutations'] << mutate

    depth = 0
    @population = []
    front_report = []
    @dom_sort.layers( combined_population ).each do |layer|
      front = Crowding.distance( layer ) { |orig, cdist| Nsga2Individual.new( orig, depth, cdist ) }
      depth += 1
      empty_slots = @population_size - @population.size
      front_report << front.size
      if empty_slots > front.size 
        @population.concat front
      else
        front.sort! { |a,b| b.crowding <=> a.crowding }
        @population.concat front[0...empty_slots]
      end
    end

    @report['fronts_sizes'] << front_report.inspect

    return @report
  end

  def teardown
    @report << "--------- finished:"
    @population.map! { |individual| individual.orig }   
    @store.save @population
    return @report   
  end

  def finished?
    population = @population.map { |individual| individual.orig }   
    max_steps = @termination['max_steps']
    on_individual = @termination['on_individual']

    if ( not max_steps.nil? and @steps >= max_steps ) or
       ( not on_individual.nil? and population.detect { |individual| individual.send on_individual } )
 
      @report.report population

      return true
    end
    return false
  end
 
 
end
 
