#!/usr/bin/ruby

require 'test/unit'
require 'lib/ranking'

class TrivialIndividual < Struct.new( :fitness )
end

class LikeTrivialIndividual < Struct.new( :val )
  def fitness
    @val * 2
  end
end

class ComplexIndividual < Struct.new( :scalar, :vector )
  attr_accessor :scalarRank, :scalarProportion
  attr_accessor :vectorRank, :vectorProportion  
end

class TC_Rank < Test::Unit::TestCase

  def setup
    @population = []
    @population << TrivialIndividual.new( 1000 )   # rank 1
    @population << TrivialIndividual.new( 30 )     # rank 4
    @population << TrivialIndividual.new( 3000 )   # rank 0
    @population << TrivialIndividual.new( 400 )    # rank 3
    @population << TrivialIndividual.new( 500 )    # rank 2
  end

  def test_basic
    r = Ranking.new :fitness
    rankedPopulation = r.rank @population 

    assert_equal( @population[0], rankedPopulation[0].original )
    assert_equal( @population[1], rankedPopulation[1].original )
    assert_equal( @population[2], rankedPopulation[2].original )
    assert_equal( @population[3], rankedPopulation[3].original )
    assert_equal( @population[4], rankedPopulation[4].original )
   
    assert_equal( 1, rankedPopulation[0].rank )
    assert_equal( 4, rankedPopulation[1].rank )
    assert_equal( 0, rankedPopulation[2].rank )
    assert_equal( 3, rankedPopulation[3].rank )
    assert_equal( 2, rankedPopulation[4].rank )

    assert_equal( 1.05, rankedPopulation[0].proportion )
    assert_equal( 0.9, (100*rankedPopulation[1].proportion).round/100.0 ) #rounding kind of 0.900001 
    assert_equal( 1.1, rankedPopulation[2].proportion )
    assert_equal( 0.95, rankedPopulation[3].proportion )
    assert_equal( 1, rankedPopulation[4].proportion )
  end

  def test_block
    #r = Ranking.new :scalar
    #r.rank( population ) {|individual,rank,prop| individual.scalarRank=rank; individual.scalarProportion=prop }
  end

  def test_equal_fitness_values
  end

  def test_heterogenous_population
  end

  def test_min_max_params
  end

  def test_proc
    # r = Ranking.new {|one,two| two.vector.size<=>one.vector.size} )
  end

  def test_already_defined_attributes
  end
end

