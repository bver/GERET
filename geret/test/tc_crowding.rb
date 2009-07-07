#!/usr/bin/ruby

require 'test/unit'
require 'lib/crowding'

include Moea

class CrowdPair < Struct.new( :x, :y )
  include Pareto
  Pareto.minimize CrowdPair, :x
  Pareto.maximize CrowdPair, :y 
end

class CrowdTriplet < Struct.new( :x, :y, :distance )
  include Pareto
  Pareto.minimize CrowdTriplet, :x
  Pareto.maximize CrowdTriplet, :y 
end

class TC_Crowding < Test::Unit::TestCase
  def setup
    @population = []   
    @population << CrowdPair.new( 0, 7 ) 
    @population << CrowdPair.new( 1, 6 ) 
    @population << CrowdPair.new( 2, 3 ) 
    @population << CrowdPair.new( 7, 2 ) 
    @population << CrowdPair.new( 7, 2 ) 
    @population << CrowdPair.new( 10, 2 )    
  end

  def test_five_points
    crowd = Crowding.distance @population

    @population.each_index do |i| 
      assert_equal( @population[i].object_id, crowd[i].original.object_id )
    end

    assert_equal( Crowding::Inf, crowd[0].cdist )
    assert_equal( 1.0, crowd[1].cdist )
    assert_equal( 1.4, crowd[2].cdist )
    assert_equal( 0.3, crowd[3].cdist )   
    assert_equal( 0.7, crowd[4].cdist )    
    assert_equal( Crowding::Inf, crowd[5].cdist )
  end

  def test_block
    population = Crowding.distance( @population ) { |t,dist| CrowdTriplet.new( t.x, t.y, dist ) }
    assert_equal( @population.size, population.size )

    population.each_with_index do |c,i|
      assert_equal( @population[i].x, c.x )
      assert_equal( @population[i].y, c.y )    
    end

    assert_equal( Crowding::Inf, population[0].distance )
    assert_equal( 1.0, population[1].distance )
    assert_equal( 1.4, population[2].distance )
    assert_equal( 0.3, population[3].distance )   
    assert_equal( 0.7, population[4].distance )    
    assert_equal( Crowding::Inf, population[5].distance )
  end

  def test_empty_population
    exception = assert_raise( RuntimeError ) { Crowding.distance [] }
    assert_equal( "Crowding: cannot compute empty population", exception.message )
  end

  def test_population_size_1
    population = [ CrowdPair.new( 2, 3 ) ]
   
    crowd = Crowding.distance population
    assert_equal( 1, crowd.size )
    assert_equal( population.first.object_id, crowd.first.original.object_id ) 
    assert_equal( Crowding::Inf, crowd.first.cdist )
  end
  
end

