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
    population = []
    population << ComplexIndividual.new( 1000 )   # rank 1
    population << ComplexIndividual.new( 30 )     # rank 4
    population << ComplexIndividual.new( 3000 )   # rank 0
    population << ComplexIndividual.new( 400 )    # rank 3
    population << ComplexIndividual.new( 500 )    # rank 2
   
    r = Ranking.new :scalar
    r.rank( population ) {|individual,rank,prop| individual.scalarRank=rank; individual.scalarProportion=prop }

    assert_equal( 1, population[0].scalarRank )
    assert_equal( 4, population[1].scalarRank )
    assert_equal( 0, population[2].scalarRank )
    assert_equal( 3, population[3].scalarRank )
    assert_equal( 2, population[4].scalarRank )

    assert_equal( 1.05, population[0].scalarProportion )
    assert_equal( 0.9, (100*population[1].scalarProportion).round/100.0 ) #rounding kind of 0.900001 
    assert_equal( 1.1, population[2].scalarProportion )
    assert_equal( 0.95, population[3].scalarProportion )
    assert_equal( 1, population[4].scalarProportion )
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

end

