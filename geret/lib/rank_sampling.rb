
require 'lib/sampling'
require 'lib/ranking'

module Selection

  class RankSampling < Sampling

    def initialize ranker
      raise "RankSampling: invalid Ranking object" unless ranker.kind_of? Ranking     
      @ranker = ranker
      super :proportion
    end

    def select( how_much, population=self.population )
      super( how_much, @ranker.rank( population ) ).map { |individual| individual.original }
    end

  end

end


