
require 'lib/sampling'
require 'lib/ranking'

module Selection

  class RankSampling < Sampling

    def initialize ranker
      raise "RankSampling: invalid Ranking object" unless ranker.kind_of? Ranking     
      @ranker = ranker
      super :proportion
    end

    def select( population, how_much )
      super( @ranker.rank( population ), how_much ).map { |individual| individual.original }
    end

  end

end


