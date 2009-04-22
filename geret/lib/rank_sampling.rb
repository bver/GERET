
require 'lib/sampling'
require 'lib/ranking'

module Selection

  class RankSampling

    def initialize ranker
      raise "RankSampling: invalid Ranking object" unless ranker.kind_of? Ranking     
      @ranker = ranker
      @sampling = Sampling.new :proportion
      @population = nil     
      @ranked = nil
    end
  
    attr_accessor :population

    def random= rnd
      @sampling.random = rnd
    end

    def select( how_much, population=self.population )
      @ranked = @ranker.rank( population ) 
      @population = population
     
      @sampling.select( how_much, @ranker.rank( population ) ).map { |individual| individual.original }
    end

    def select_one population=self.population
      select( 1, population ).first
    end
    
  end

end


