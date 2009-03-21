#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/roulette'

SomeIndividual = Struct.new( 'SomeIndividual', :fitness )

class TC_Roulette < Test::Unit::TestCase
  def setup
    @population = []
    @population << SomeIndividual.new(10)
    @population << SomeIndividual.new(100)
    @population << SomeIndividual.new(50)
    @population << SomeIndividual.new(10)
    # sum is 170
  end

  def test_basic
    r = Roulette.new :fitness
    r.random =  MockRand.new [{0,0.3}, {0,0.7}]

    winner = r.select @population
    assert_equal( @population[1].object_id, winner.object_id )

    winner = r.select @population
    assert_equal( @population[2].object_id, winner.object_id )
  end

  def test_ballot_overrun
    r = Roulette.new :fitness
    r.random =  MockRand.new [{0,0.5}]

    zero = SomeIndividual.new 0
    winner = r.select [ zero ]
    assert_equal( zero.object_id, winner.object_id )
  end

end

