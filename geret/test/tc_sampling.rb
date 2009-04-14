#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/sampling'

include Selection

SUIndividual = Struct.new( 'SUIndividual', :fitness )

class TC_Sampling < Test::Unit::TestCase
  
  def setup
    @population = []
    @population << SUIndividual.new(10)
    @population << SUIndividual.new(100)
    @population << SUIndividual.new(50)
    @population << SUIndividual.new(10)
    # sum is 170
  end
 
  def test_basic
    r = Sampling.new :fitness
    r.random =  MockRand.new [{0=>0.3}]

    winners = r.select( @population, 2 )
    assert_equal( 2, winners.size )
    assert_equal( @population[1].object_id, winners[0].object_id )
    assert_equal( @population[2].object_id, winners[1].object_id )
  end

  def test_proc
    r = Sampling.new { |item| item }
    r.random =  MockRand.new [{0=>0.3}]

    population = [10, 100, 50, 10]
    winners = r.select( population, 2 )
    assert_equal( 100, winners[0] )
    assert_equal( 50, winners[1] )
  end

  def test_small_population
    r = Sampling.new :fitness
    exception = assert_raise( RuntimeError ) { r.select( @population, 5 ) }
    assert_equal( "Sampling: cannot select more than population.size", exception.message )
  end

  def test_empty_population
    r = Sampling.new :fitness
    exception = assert_raise( RuntimeError ) { r.select( [], 2 ) }
    assert_equal( "Sampling: cannot select from an empty population", exception.message )
  end

  def test_zero_howmuch
    r = Sampling.new :fitness
    winners = r.select( @population, 0 )
    assert_equal( 0, winners.size )
  end  

  def test_select_one
    r = Sampling.new :fitness
    r.random =  MockRand.new [{0=>0.3}]

    winners = r.select_one( @population )
    assert_equal( 1, winners.size )
    assert_equal( @population[1].object_id, winners[0].object_id )
  end

  def test_attributes
    r = Sampling.new :fitness   
    assert_equal( :fitness, r.proportional_by )
    r.proportional_by = :some_arg
    assert_equal( :some_arg, r.proportional_by )

    r = Sampling.new { |item| item }   
    assert_equal( nil, r.proportional_by )
    r.proportional_by = :fitness
    assert_equal( :fitness, r.proportional_by )
    r.random =  MockRand.new [{0=>0.3}]
    winners = r.select( @population, 1 )
    assert_equal( 1, winners.size )
    assert_equal( @population[1].object_id, winners[0].object_id )
  end

end

