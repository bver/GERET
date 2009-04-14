#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/rank_roulette'

include Selection

RRIndividual = Struct.new( 'RRIndividual', :fitness )

class TC_RankRoulette < Test::Unit::TestCase
  
  def setup
    @population = []
    @population << RRIndividual.new( 1000 )   # rank 1
    @population << RRIndividual.new( 30 )     # rank 4
    @population << RRIndividual.new( 3000 )   # rank 0
    @population << RRIndividual.new( 400 )    # rank 3
    @population << RRIndividual.new( 500 )    # rank 2
  end

  def test_basic
    rank = Ranking.new :fitness
    r = RankRoulette.new rank
    r.random =  MockRand.new [{0=>0.3}, {0=>0.7}, {0=>0.3}, {0=>0.7}]
   
    winner = r.select_one @population
    assert_equal( @population[0].object_id, winner.object_id )

    winners = r.select( @population, 2 )
    assert_equal( 2, winners.size )
    assert_equal( @population[3].object_id, winners[0].object_id )
    assert_equal( @population[0].object_id, winners[1].object_id )
  end
 
  def test_invalid_ranker
    exception = assert_raise( RuntimeError ) { RankRoulette.new( 42 ) }
    assert_equal( "RankRoulette: invalid Ranking object", exception.message )
  end
  
end

