
require 'lib/ranking'
require 'lib/select_more'

module Selection

  class Tournament
    include SelectMore

    def initialize ranker, tournament_size=2, pressure_modifier=1.0
      raise "Tournament: invalid Ranking object" unless ranker.kind_of? Ranking 
      @ranker = ranker
      @tournament_size = tournament_size 
      @random = Kernel
      @pressure_modifier = pressure_modifier
    end

    attr_accessor :tournament_size, :ranker, :random, :pressure_modifier

    def select_one population
      raise "Tournament: empty population" if population.empty?
      raise "Tournament: tournament_size bigger than population.size" if @tournament_size > population.size 
     
      selected = []
      while selected.size < @tournament_size
        selected.push population[ @random.rand(population.size) ]
      end

      ranked = @ranker.rank selected
      for rank in ( 0 ... @tournament_size )
        next if @random.rand > @pressure_modifier and rank < @tournament_size-1
        selection = ranked.find_all { |individual| individual.rank == rank }
        return selection[ @random.rand(selection.size) ].original
      end
    end

  end

end # Selection

