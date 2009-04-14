#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/rank_sampling'

include Selection

RSIndividual = Struct.new( 'RSIndividual', :fitness )

class TC_RankSampling < Test::Unit::TestCase
  
  def setup
    @population = []
    @population << RSIndividual.new( 1000 )   # rank 1
    @population << RSIndividual.new( 30 )     # rank 4
    @population << RSIndividual.new( 3000 )   # rank 0
    @population << RSIndividual.new( 400 )    # rank 3
    @population << RSIndividual.new( 500 )    # rank 2
  end

  def test_basic
    rank = Ranking.new :fitness
    r = RankSampling.new rank
    r.random =  MockRand.new [{0=>0.3}, {0=>0.7}, {0=>0.3}, {0=>0.7}]
   
    winner = r.select_one @population
    assert_equal( @population[0].object_id, winner.object_id )

    winners = r.select( 2, @population )
    assert_equal( 2, winners.size )
    assert_equal( @population[0].object_id, winners[0].object_id )
    assert_equal( @population[1].object_id, winners[1].object_id )
  end
 
  def test_invalid_ranker
    exception = assert_raise( RuntimeError ) { RankSampling.new( 42 ) }
    assert_equal( "RankSampling: invalid Ranking object", exception.message )
  end
  
end

