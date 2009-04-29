
module Selection
  class ParetoTourney

    def initialize tournament_size
      @tournament_size = tournament_size
      @random = Kernel
    end

    attr_accessor :random, :population, :tournament_size 

    def select_front population=self.population
      ParetoTourney.front( random_select( population ) )
    end

    def select_dominated population=self.population
      ParetoTourney.dominated( random_select( population ) )
    end
   
    def ParetoTourney.front selection
      front = []
      selection.each do |individual|

        next if front.detect { |f| f.dominates? individual }

        removal = []
        front.each do |f|
          next unless individual.dominates? f
          removal.push f
        end
        removal.each { |r| front.delete r }
        
        front.push individual
      end

      front
    end

    def ParetoTourney.dominated selection
      ids = ParetoTourney.front( selection ).map { |dominated| dominated.object_id }
      selection.delete_if { |individual| ids.include? individual.object_id }
      selection
    end

    protected

    def random_select population
      raise "ParetoTourney: empty population" if population.empty?
      raise "ParetoTourney: tournament_size bigger than population.size" if @tournament_size > population.size    

      self.population = population
      pop = population.clone 

      selection = []
      @tournament_size.times { selection << pop.delete_at( @random.rand(pop.size) ) }
      selection
    end

  end
end

