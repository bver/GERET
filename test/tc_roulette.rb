
$LOAD_PATH << '.' unless $LOAD_PATH.include? '.'

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
    r.random =  MockRand.new [{0=>0.3}, {0=>0.7}]

    winner = r.select_one @population
    assert_equal( @population[1].object_id, winner.object_id )

    winner = r.select_one @population
    assert_equal( @population[2].object_id, winner.object_id )
  end

  def test_ballot_overrun
    r = Roulette.new :fitness
    r.random =  MockRand.new [{0=>0.5}]

    zero = SomeIndividual.new 0
    winner = r.select_one [ zero ]
    assert_equal( zero.object_id, winner.object_id )
  end

  def test_empty_population
    r = Roulette.new :fitness
    exception = assert_raise( RuntimeError ) { r.select_one [] }
    assert_equal( "Roulette: cannot select from an empty population", exception.message )
  end

  def test_negative_fitness
    r = Roulette.new :fitness
    @population << SomeIndividual.new(-1)
    exception = assert_raise( RuntimeError ) { r.select_one @population }
    assert_equal( "Roulette: cannot use a negative slot width", exception.message )
  end

  def test_proc
    r = Roulette.new { |item| item }
    r.random =  MockRand.new [{0=>0.3}, {0=>0.7}]

    population = [10, 100, 50, 10]
    winner = r.select_one population
    assert_equal( 100, winner )

    winner = r.select_one population
    assert_equal( 50, winner )
  end

  def test_more
    r = Roulette.new :fitness
    r.random =  MockRand.new [{0=>0.3}, {0=>0.7}]

    winners = r.select( 2, @population )
    assert_equal( 2, winners.size )
    assert_equal( @population[1].object_id, winners[0].object_id )
    assert_equal( @population[2].object_id, winners[1].object_id )
  end

  def test_unique
    r = Roulette.new :fitness
    assert_equal( false, r.unique_winners )

    r.random =  MockRand.new [{0=>0.3}, {0=>0.3}]
    winners = r.select( 2, @population )
    assert_equal( 2, winners.size )
    assert_equal( @population[1].object_id, winners[0].object_id )
    assert_equal( @population[1].object_id, winners[1].object_id )

    r.unique_winners = true
    assert_equal( true, r.unique_winners )

    r.random =  MockRand.new [{0=>0.3}, {0=>0.3}, {0=>0.7}]
    winners = r.select( 2, @population )
    assert_equal( 2, winners.size )
    assert_equal( @population[1].object_id, winners[0].object_id )
    assert_equal( @population[2].object_id, winners[1].object_id )
  end

  def test_attributes
    r = Roulette.new :fitness   
    assert_equal( :fitness, r.proportional_by )
    r.proportional_by = :some_arg
    assert_equal( :some_arg, r.proportional_by )

    r = Roulette.new { |item| item }   
    assert_equal( nil, r.proportional_by )
    r.proportional_by = :fitness
    assert_equal( :fitness, r.proportional_by )
    r.random =  MockRand.new [{0=>0.3}, {0=>0.7}]
    winner = r.select_one @population
    assert_equal( @population[1].object_id, winner.object_id )
  end

  def test_population_attr
    r = Roulette.new :fitness

    assert_equal( nil, r.population )
    r.population = @population
    assert_equal( @population.object_id, r.population.object_id )

    r.random =  MockRand.new [{0=>0.3}, {0=>0.3}, {0=>0.7}]   
    winner = r.select_one
    assert_equal( @population[1].object_id, winner.object_id )

    winners = r.select 2
    assert_equal( 2, winners.size )
    assert_equal( @population[1].object_id, winners[0].object_id )
    assert_equal( @population[2].object_id, winners[1].object_id )
  end
 
end

