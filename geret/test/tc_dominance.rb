#!/usr/bin/ruby

require 'test/unit'
require 'lib/dominance'

class Point2D < Struct.new( :x, :y )
  def <=> other
    return 1 if (self.x >= other.x and self.y > other.y) or (self.x > other.x and self.y >= other.y)
    return -1 if (self.x <= other.x and self.y < other.y) or (self.x < other.x and self.y <= other.y)
    return 0
  end

  def nondominance other
    return other <=> self
  end 
end

class SmartPoint < Point2D
  attr_accessor :smartRank, :smartCount, :smartDepth
end

class TC_Dominance < Test::Unit::TestCase

  def setup
    @population = []
    @population << Point2D.new( 2, 6 ) #a
    @population << Point2D.new( 3, 5 ) #b
    @population << Point2D.new( 5, 5 ) #c
    @population << Point2D.new( 1, 4 ) #d
    @population << Point2D.new( 4, 4 ) #e
    @population << Point2D.new( 7, 3 ) #f
    @population << Point2D.new( 4, 2 ) #g
    @population << Point2D.new( 3, 1 ) #h
  end

  def test_rank_count_basic
    d = Dominance.new
    rankedPopulation = d.rank_count @population

    @population.each_index { |i| assert_equal( @population[i].object_id, rankedPopulation[i].original.object_id ) }

    assert_equal( 0, rankedPopulation[0].rank )
    assert_equal( 1, rankedPopulation[1].rank )
    assert_equal( 0, rankedPopulation[2].rank )
    assert_equal( 4, rankedPopulation[3].rank )
    assert_equal( 1, rankedPopulation[4].rank )
    assert_equal( 0, rankedPopulation[5].rank )
    assert_equal( 3, rankedPopulation[6].rank )   
    assert_equal( 5, rankedPopulation[7].rank )  

    assert_equal( 1, rankedPopulation[0].count )
    assert_equal( 2, rankedPopulation[1].count )
    assert_equal( 5, rankedPopulation[2].count )
    assert_equal( 0, rankedPopulation[3].count )
    assert_equal( 3, rankedPopulation[4].count )
    assert_equal( 2, rankedPopulation[5].count )
    assert_equal( 1, rankedPopulation[6].count )   
    assert_equal( 0, rankedPopulation[7].count )  
  end

  def test_rank_count_block
 
    population = []
    population << SmartPoint.new( 2, 6 ) #a
    population << SmartPoint.new( 3, 5 ) #b
    population << SmartPoint.new( 5, 5 ) #c
    population << SmartPoint.new( 1, 4 ) #d
    population << SmartPoint.new( 4, 4 ) #e
    population << SmartPoint.new( 7, 3 ) #f
    population << SmartPoint.new( 4, 2 ) #g
    population << SmartPoint.new( 3, 1 ) #h

    d = Dominance.new
    d.rank_count( population ) do |individual,rank,count| 
       individual.smartRank = rank 
       individual.smartCount = count
    end

    assert_equal( 0, population[0].smartRank )
    assert_equal( 1, population[1].smartRank )
    assert_equal( 0, population[2].smartRank )
    assert_equal( 4, population[3].smartRank )
    assert_equal( 1, population[4].smartRank )
    assert_equal( 0, population[5].smartRank )
    assert_equal( 3, population[6].smartRank )   
    assert_equal( 5, population[7].smartRank )  

    assert_equal( 1, population[0].smartCount )
    assert_equal( 2, population[1].smartCount )
    assert_equal( 5, population[2].smartCount )
    assert_equal( 0, population[3].smartCount )
    assert_equal( 3, population[4].smartCount )
    assert_equal( 2, population[5].smartCount )
    assert_equal( 1, population[6].smartCount )   
    assert_equal( 0, population[7].smartCount )  
  end
 
  def test_rank_count_proc
    d = Dominance.new( proc {|a,b| a.nondominance b } )
    rankedPopulation = d.rank_count @population

    assert_equal( 0, rankedPopulation[0].count )
    assert_equal( 1, rankedPopulation[1].count )
    assert_equal( 0, rankedPopulation[2].count )
    assert_equal( 4, rankedPopulation[3].count )
    assert_equal( 1, rankedPopulation[4].count )
    assert_equal( 0, rankedPopulation[5].count )
    assert_equal( 3, rankedPopulation[6].count )   
    assert_equal( 5, rankedPopulation[7].count )  

    assert_equal( 1, rankedPopulation[0].rank )
    assert_equal( 2, rankedPopulation[1].rank )
    assert_equal( 5, rankedPopulation[2].rank )
    assert_equal( 0, rankedPopulation[3].rank )
    assert_equal( 3, rankedPopulation[4].rank )
    assert_equal( 2, rankedPopulation[5].rank )
    assert_equal( 1, rankedPopulation[6].rank )   
    assert_equal( 0, rankedPopulation[7].rank )  
  end

  def test_rank_count_empty_population
    d = Dominance.new
    rankedPopulation = d.rank_count []
    assert( rankedPopulation.empty? )
  end

  def test_rank_count_small_population
    d = Dominance.new
    rankedPopulation = d.rank_count [ Point2D.new( 3, 1 ) ]
    assert_equal( 0, rankedPopulation[0].rank )
    assert_equal( 0, rankedPopulation[0].count ) 
  end
 
  def test_depth_basic
    d = Dominance.new
    rankedPopulation = d.depth @population

    @population.each_index { |i| assert_equal( @population[i].object_id, rankedPopulation[i].original.object_id ) }

    assert_equal( 0, rankedPopulation[0].depth )
    assert_equal( 1, rankedPopulation[1].depth )
    assert_equal( 0, rankedPopulation[2].depth )
    assert_equal( 2, rankedPopulation[3].depth )
    assert_equal( 1, rankedPopulation[4].depth )
    assert_equal( 0, rankedPopulation[5].depth )
    assert_equal( 2, rankedPopulation[6].depth )   
    assert_equal( 3, rankedPopulation[7].depth )  
  end

  def xtest_depth_block
    d = Dominance.new
    d.depth( @population ) { |individual,depth| individual.smartDepth = depth }
  end
 
  def xtest_depth_proc
    d = Dominance.new( proc {|a,b| a.nondominance b } )
    rankedPopulation = d.depth @population
  end

  def xtest_depth_empty_population
  end

  def xtest_depth_small_population
  end
  
end

