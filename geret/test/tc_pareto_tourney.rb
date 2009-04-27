#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/pareto_tourney'

class PointPT < Struct.new( :id, :x, :y )
  def dominates? other
    (self.x >= other.x and self.y > other.y) or (self.x > other.x and self.y >= other.y)
  end
end

class TC_ParetoTourney < Test::Unit::TestCase

  def setup
    @population = []
    @population << PointPT.new( 'a', 2, 6 ) # rank 0
    @population << PointPT.new( 'b', 3, 5 ) # rank 1    
    @population << PointPT.new( 'c', 5, 5 ) # rank 0
    @population << PointPT.new( 'd', 1, 4 ) # rank 4
    @population << PointPT.new( 'e', 4, 4 ) # rank 1
    @population << PointPT.new( 'f', 7, 3 ) # rank 0
    @population << PointPT.new( 'g', 4, 2 ) # rank 3
    @population << PointPT.new( 'h', 3, 1 ) # rank 5 
  end

  def test_basic
    pt = ParetoTourney.new 4
    pt.random = MockRand.new [{8=>6}, {7=>3}, {6=>2}, {5=>0}]
    winners = pt.select @population
    assert_equal( 2, winners.size )
    assert_equal( 'c', winners[0].id )
    assert_equal( 'a', winners[1].id )   

    pt.random = MockRand.new [{8=>7}, {7=>6}, {6=>5}, {5=>4}]
    assert_equal( 2, winners.size )   
    winners = pt.select @population
    assert_equal( 'f', winners[0].id )
    assert_equal( 'e', winners[1].id )   
  end

  def test_population_attr
  end

  def test_tournament_size
  end

end


