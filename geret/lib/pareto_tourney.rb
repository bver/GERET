
module Selection
  class ParetoTourney

    def initialize tournament_size=2
      @tournament_size = tournament_size
      @random = Kernel
    end

    attr_accessor :random, :population, :tournament_size 

    def select_front population=self.population
      Pareto.nondominated( random_select( population ) )
    end

    def select_dominated population=self.population
      Pareto.dominated( random_select( population ) )
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

