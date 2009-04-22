
require 'lib/roulette'
require 'lib/ranking'

module Selection

  class RankRoulette
    include SelectMore

    def initialize ranker
      raise "RankRoulette: invalid Ranking object" unless ranker.kind_of? Ranking     
      @ranker = ranker
      @roulette = Roulette.new :proportion
      @population = nil     
      @ranked = nil
    end

    attr_accessor :population
    
    def random= rnd
      @roulette.random = rnd
    end

    def select_one population=self.population
      @ranked = @ranker.rank( population ) 
      @population = population

      select_one_internal
    end

    protected

    def select_one_internal
      @roulette.select_one( @ranked ).original
    end

  end

end


