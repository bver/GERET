#!/usr/bin/ruby

require 'test/unit'
require 'lib/ranking'

class TrivialIndividual < Struct.new( :fitness )
end

class LikeTrivialIndividual 
  def initialize val
    @val = val
  end
  def fitness
    @val * 2
  end
end

class ComplexIndividual < Struct.new( :scalar, :vector )
  attr_accessor :scalarRank, :scalarProportion
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
    assert_equal( 0.9.to_s, rankedPopulation[1].proportion.to_s ) #rounding kind of 0.900001 
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
    assert_equal( 0.9.to_s, population[1].scalarProportion.to_s ) #rounding kind of 0.900001 
    assert_equal( 1.1, population[2].scalarProportion )
    assert_equal( 0.95, population[3].scalarProportion )
    assert_equal( 1, population[4].scalarProportion )
  end

  def test_equal_fitness_values
    # two plateu case: [ 20, 30,   p2:200,200,200,   500,    p1:1000,1000,   3400 ]
    fit = [ 20,    200,200, 1000, 200,   500,  3400,  1000, 30   ]     
    population = []
    fit.each {|f| population << TrivialIndividual.new( f ) }

    r = Ranking.new :fitness
    rankedPopulation = r.rank population 

    assert_equal( 5, rankedPopulation[0].rank )
    assert_equal( 3, rankedPopulation[1].rank )
    assert_equal( 3, rankedPopulation[2].rank )
    assert_equal( 1, rankedPopulation[3].rank )
    assert_equal( 3, rankedPopulation[4].rank )
    assert_equal( 2, rankedPopulation[5].rank )
    assert_equal( 0, rankedPopulation[6].rank )   
    assert_equal( 1, rankedPopulation[7].rank )  
    assert_equal( 4, rankedPopulation[8].rank )

    plateu1 = (1.075 + 1.05) / 2 # rank 1
    plateu2 = (1.0 + 0.975 + 0.95) / 3 # rank 3
    # 1.1, p1:1.075, p1:1.05, 1.025, p2:1.0, p2:0.975, p2:0.95, 0.924, 0.899
    
 
    assert_equal( 0.9.to_s, rankedPopulation[0].proportion.to_s )
    assert_equal( 0.98, rankedPopulation[1].proportion )
    assert_equal( 0.98, rankedPopulation[2].proportion )
    assert_equal( 1.06, rankedPopulation[3].proportion )
    assert_equal( 0.98, rankedPopulation[4].proportion )
    assert_equal( 1.02, rankedPopulation[5].proportion )
    assert_equal( 1.1, rankedPopulation[6].proportion )   
    assert_equal( 1.06, rankedPopulation[7].proportion )  
    assert_equal( 0.94, rankedPopulation[8].proportion )
  end

  def test_heterogenous_population
    @population[0] = LikeTrivialIndividual.new( 1000/2 )   # rank 1   
    @population[4] = LikeTrivialIndividual.new( 500/2 )    # rank 2   

    r = Ranking.new :fitness
    rankedPopulation = r.rank @population 

    assert_equal( 1, rankedPopulation[0].rank )
    assert_equal( 4, rankedPopulation[1].rank )
    assert_equal( 0, rankedPopulation[2].rank )
    assert_equal( 3, rankedPopulation[3].rank )
    assert_equal( 2, rankedPopulation[4].rank )
  end

  def test_min_max_params
    r = Ranking.new :fitness
    assert_equal( 1.1, r.max )
    assert_equal( 2-r.max, r.min )
    r.min = 9 
    r.max = 11
    assert_equal( 11, r.max )
    assert_equal( 9, r.min )
 
    rankedPopulation = r.rank @population 

    assert_equal( 10.5, rankedPopulation[0].proportion )
    assert_equal( 9, (100*rankedPopulation[1].proportion).round/100.0 ) #rounding    
    assert_equal( 11, rankedPopulation[2].proportion )
    assert_equal( 9.5, rankedPopulation[3].proportion )
    assert_equal( 10, rankedPopulation[4].proportion )
  end

  def test_proc
    population = []
    population << ComplexIndividual.new( 0, Array.new(100,7) )   # rank 1
    population << ComplexIndividual.new( 0, [5,nil,'hello'] )     # rank 4
    population << ComplexIndividual.new( 0, Array.new(300) )   # rank 0
    population << ComplexIndividual.new( 0, [7,7,7,7] )    # rank 3
    population << ComplexIndividual.new( 0, [1,1,1,1,1] )    # rank 2
  
    r = Ranking.new( proc {|one,two| two.vector.size<=>one.vector.size} )
    rankedPopulation = r.rank population 

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

  def test_minimize_argument
   # r = Ranking.new :fitness, :minimize   
  end

  def test_singleton_population
  end

  def test_empty_population
  end
end

