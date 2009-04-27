
module Selection
  class ParetoTourney

    def initialize tournament_size
      @tournament_size = tournament_size
      @random = Kernel
    end

    attr_accessor :random

    def select population
      pop = population.clone 
      selection = []
      @tournament_size.times { selection << pop.delete_at( @random.rand(pop.size) ) }
      
      front = []
      losers = []
      selection.each do |individual|

        if front.detect { |f| f.dominates? individual }
          losers.push individual
          next
        end

        removal = []
        front.each do |f|
          next unless individual.dominates? f
          losers.push f
          removal.push f
        end
        removal.each { |r| front.delete r }
        
        front.push individual
      end

      front
    end

  end
end

