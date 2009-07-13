
require 'lib/ranking'

module Selection

  # The truncation selection method. This method selects only the best individuals from the population. 
  class Truncation

    # Set the ranker object (the instance of Ranking class) necessary for comparision of individuals.
    def initialize ranker
      raise "Truncation: invalid Ranking object" unless ranker.kind_of? Ranking     
      @ranker = ranker
      @population = nil     
    end
     
    # The population to select from.
    attr_accessor :population

    # Select N-best individuals from the population (N==how_much)
    def select( how_much, population=self.population )
      ranked = @ranker.rank( population ).map { |individual| individual.original }
      @population = population
     
      ranked[0...how_much]
    end

    # Select only the best individual from the population.
    def select_one population=self.population
      select( 1, population ).first
    end

  end
  
end
