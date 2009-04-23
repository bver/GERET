
require 'lib/ranking'

module Selection

  class Truncation

    def initialize ranker
      raise "Truncation: invalid Ranking object" unless ranker.kind_of? Ranking     
      @ranker = ranker
      @population = nil     
    end
     
    attr_accessor :population

    def select( how_much, population=self.population )
      ranked = @ranker.rank( population ).map { |individual| individual.original }
      @population = population
     
      ranked[0...how_much]
    end

    def select_one population=self.population
      select( 1, population ).first
    end

  end
  
end
