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
    @population << TrmntIndividual.new(10)
    @population << TrmntIndividual.new(100)
    @population << TrmntIndividual.new(50)
    @population << TrmntIndividual.new(10)
  end

  def test_basic
    r = Ranking.new :fitness 
    t = Tournament.new( r, 2 )
    t.random = MockRand.new [{0=>0.8}, {1=>0}]

    assert_equal( r.object_id, t.ranker.object_id )

    winner = t.select_one @population 
    assert_equal( @population[1].object_id, winner.object_id )
  end

  def test_two_candidates
    r = Ranking.new :fitness, :minimize 
    t = Tournament.new( r, 3 )

    t.random = MockRand.new [{0=>0.8}, {2=>1}]
    winner = t.select_one @population
    assert_equal( @population[3].object_id, winner.object_id )

    t.random = MockRand.new [{0=>0.8}, {2=>0}]
    winner = t.select_one @population
    assert_equal( @population[0].object_id, winner.object_id )
  end

  def test_pressure_modifier
    r = Ranking.new :fitness 
    t = Tournament.new( r, 3 )   
    assert_equal( 1.0, t.pressure_modifier )
    t.pressure_modifier = 0.5
    assert_equal( 0.5, t.pressure_modifier )

    t = Tournament.new( r, 3, 0.7 )
    assert_equal( 0.7, t.pressure_modifier )
    t.random = MockRand.new [{0=>0.8}, {0=>0.5}, {1=>0} ] 

    winner = t.select_one @population
    assert_equal( @population[2].object_id, winner.object_id )
  end

  def test_tour_size
    r = Ranking.new :fitness 
    t = Tournament.new( r, 42 )
    assert_equal( 42, t.tournament_size )
    t.tournament_size = 2 
    assert_equal( 2, t.tournament_size )  

    t.random = MockRand.new [{0=>0.8}, {1=>0}]
    winner = t.select_one( @population )
    assert_equal( @population[1].object_id, winner.object_id )
  end

  def test_default_toursize
    r = Ranking.new :fitness
    assert_equal( 2, Tournament.new(r).tournament_size ) 
  end

  def test_not_lucky
    r = Ranking.new :fitness 
    t = Tournament.new( r, 2, 0.7 )
    assert_equal( 0.7, t.pressure_modifier )
    t.random = MockRand.new [{0=>0.8}, {0=>0.9}, {1=>0} ] 

    winner = t.select_one @population
    assert_equal( @population[2].object_id, winner.object_id )
  end

  def test_too_big_tournament_size
    r = Ranking.new :fitness 
    t = Tournament.new( r, 5 )
    exception = assert_raise( RuntimeError ) { t.select_one( @population ) }
    assert_equal( "Tournament: tournament_size bigger than population.size", exception.message )
  end

  def test_empty_population
    r = Ranking.new :fitness 
    t = Tournament.new( r, 5 )
    exception = assert_raise( RuntimeError ) { t.select_one( [] ) }
    assert_equal( "Ranking: empty population", exception.message )
  end

  def test_invalid_ranker
    exception = assert_raise( RuntimeError ) { Tournament.new( 42, 2 ) }
    assert_equal( "Tournament: invalid Ranking object", exception.message )
  end
  
  def test_more
    r = Ranking.new :fitness, :minimize 
    t = Tournament.new( r, 3 )

    t.random = MockRand.new [{0=>0.8}, {2=>1}, {0=>0.7}, {2=>0}]
    winners = t.select( @population, 2 )
    assert_equal( 2, winners.size )
    assert_equal( @population[3].object_id, winners[0].object_id )
    assert_equal( @population[0].object_id, winners[1].object_id )
  end

  def test_unique
    r = Ranking.new :fitness, :minimize 
    t = Tournament.new( r, 3 )
    assert_equal( false, t.unique_winners )
 
    t.random = MockRand.new [{0=>0.8}, {2=>1}, {0=>0.7}, {2=>1}]
    winners = t.select( @population, 2 )
    assert_equal( 2, winners.size )
    assert_equal( @population[3].object_id, winners[0].object_id )
    assert_equal( @population[3].object_id, winners[1].object_id )

    t.unique_winners = true
    assert_equal( true, t.unique_winners )

    t.random = MockRand.new [{0=>0.8}, {2=>1}, {0=>0.7}, {2=>1}, {0=>0.5}, {2=>0}]
    winners = t.select( @population, 2 )
    assert_equal( 2, winners.size )
    assert_equal( @population[3].object_id, winners[0].object_id )
    assert_equal( @population[0].object_id, winners[1].object_id )
  end

end

