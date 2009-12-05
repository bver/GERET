
require 'lib/pareto'

module Selection
  
  # ParetoTourneySelect method (without replacement) as described in:
  # http://www.evolved-analytics.com/selected_publications/pursuing_the_pareto_paradig.html
  #
  class ParetoTourney

    # Set the tournament_size (see the attribute) for selections.
    def initialize tournament_size=2
      @tournament_size = tournament_size
      @random = Kernel
    end

    # The source of randomness, used for calling "random.rand( limit )", defaulting to 'Kernel' class.
    attr_accessor :random
   
    # The population to select from. The same as the argument of ParetoTourney#select_front and ParetoTourney#select_dominated methods.
    attr_accessor :population 

    # The number of randomly selected individuals for dominance evaluation.
    attr_accessor :tournament_size

    # Select all nondominated solutions from the random subset of the population.
    def select_front population=self.population
      Moea::Pareto.nondominated( random_select( population ) )
    end

    # Select all dominated solutions from the random subset of the population.   
    def select_dominated population=self.population
      Moea::Pareto.dominated( random_select( population ) )
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

