#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/roulette'

include Selection

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

  def test_empty_population
    r = Roulette.new :fitness
    exception = assert_raise( RuntimeError ) { r.select [] }
    assert_equal( "Roulette: cannot select from an empty population", exception.message )
  end

  def test_negative_fitness
    r = Roulette.new :fitness
    @population << SomeIndividual.new(-1)
    exception = assert_raise( RuntimeError ) { r.select @population }
    assert_equal( "Roulette: cannot use a negative slot width", exception.message )
  end

  def test_proc
    r = Roulette.new proc { |item| item }
    r.random =  MockRand.new [{0,0.3}, {0,0.7}]

    population = [10, 100, 50, 10]
    winner = r.select population
    assert_equal( 100, winner )

    winner = r.select population
    assert_equal( 50, winner )
  end



end

