#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/tournament'

include Selection

class TrmntIndividual < Struct.new( :fitness )
  def oposite_ranking( other )
    other.fitness <=> self.fitness 
  end
end


class TC_Tournament < Test::Unit::TestCase

  def setup
    @population = []
    @population << SUIndividual.new(10)
    @population << SUIndividual.new(100)
    @population << SUIndividual.new(50)
    @population << SUIndividual.new(10)
  end

  def test_basic
    r = Ranking.new :fitness 
    t = Tournament.new r
    assert_equal( r.object_id, t.ranker.object_id )

    winner = t.select( @population, 2 )
    assert_equal( @population[1].object_id, winner.object_id )
  end

  def test_two_candidates
    r = Ranking.new :fitness, :minimize 
    t = Tournament.new r

    t.random = MockRand.new [{2,1}]
    winner = t.select( @population, 3 )
    assert_equal( @population[3].object_id, winner.object_id )

    t.random = MockRand.new [{2,0}]
    winner = t.select( @population, 3 )
    assert_equal( @population[0].object_id, winner.object_id )
  end
  
end

