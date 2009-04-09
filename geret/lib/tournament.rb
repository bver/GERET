
require 'lib/ranking'

module Selection

  class Tournament

    def initialize ranker, tournament_size, pressure_modifier=1.0
      raise "Tournament: invalid Ranking object" unless ranker.kind_of? Ranking 
      @ranker = ranker
      @tournament_size = tournament_size 
      @random = Kernel
      @pressure_modifier = pressure_modifier
    end

    attr_accessor :tournament_size, :ranker, :random, :pressure_modifier

    def select population
      ranked = @ranker.rank population
      raise "Tournament: tournament_size bigger than population.size" if @tournament_size > population.size 

      for rank in ( 0 ... @tournament_size )
        next if @random.rand > @pressure_modifier and rank < @tournament_size-1
        selection = ranked.find_all { |individual| individual.rank == rank }
        return selection[ @random.rand(selection.size) ].original
      end
    end

  end

end # Selection

