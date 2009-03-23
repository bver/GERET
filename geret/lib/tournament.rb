
require 'lib/ranking'

class Tournament
  def initialize ranker
    @ranker = ranker
    @random = Kernel   
  end

  attr_accessor :ranker, :random

  def select population, tournament_size
    ranked = @ranker.rank population
    ranked = ranked.find_all { |individual| individual.rank < tournament_size }
   
    rank = 0
    selection = ranked.find_all { |individual| individual.rank == rank }
    
    return selection.first.original if selection.size == 1
    selection[ @random.rand(selection.size) ].original
  end

end

