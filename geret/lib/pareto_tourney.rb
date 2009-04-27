
module Selection
  class ParetoTourney

    def initialize tournament_size
      @tournament_size = tournament_size
      @random = Kernel
    end

    attr_accessor :random, :population, :tournament_size 

    def select population=self.population
      raise "ParetoTourney: empty population" if population.empty?
      raise "ParetoTourney: tournament_size bigger than population.size" if @tournament_size > population.size    

      self.population = population
      pop = population.clone 

      selection = []
      @tournament_size.times { selection << pop.delete_at( @random.rand(pop.size) ) }
      
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

  end
end

