
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
      @ranked = @ranker.rank( population ) if @ranked.nil? or population.object_id != @population.object_id 
      @population = population

      @roulette.select_one( @ranked ).original
    end

  end

end


