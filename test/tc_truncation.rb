#!/usr/bin/ruby

require 'test/unit'
require 'lib/truncation'

include Selection

RTIndividual = Struct.new( 'RTIndividual', :fitness )

class TC_Truncation < Test::Unit::TestCase
  
  def setup
    @population = []
    @population << RTIndividual.new( 1000 )   # rank 1
    @population << RTIndividual.new( 30 )     # rank 4
    @population << RTIndividual.new( 3000 )   # rank 0
    @population << RTIndividual.new( 400 )    # rank 3
    @population << RTIndividual.new( 500 )    # rank 2
  end

  def test_basic
    rank = Ranking.new :fitness
    r = Truncation.new rank
   
    winner = r.select_one @population
    assert_equal( @population[2].object_id, winner.object_id )

    winners = r.select( 3, @population )
    assert_equal( 3, winners.size )
    assert_equal( @population[2].object_id, winners[0].object_id )
    assert_equal( @population[0].object_id, winners[1].object_id )
    assert_equal( @population[4].object_id, winners[2].object_id )  
  end
 
  def test_invalid_ranker
    exception = assert_raise( RuntimeError ) { Truncation.new( 42 ) }
    assert_equal( "Truncation: invalid Ranking object", exception.message )
  end
  
  def test_population_attr
    rank = Ranking.new :fitness
    r = Truncation.new rank

    assert_equal( nil, r.population )
    r.population = @population
    assert_equal( @population.object_id, r.population.object_id )
    
    winner = r.select_one
    assert_equal( @population[2].object_id, winner.object_id )

    winners = r.select( 2 )
    assert_equal( 2, winners.size )
    assert_equal( @population[2].object_id, winners[0].object_id )
    assert_equal( @population[0].object_id, winners[1].object_id )
  end
  
end

