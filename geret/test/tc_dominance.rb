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

  def xtest_rank_count_block
    d = Dominance.new
    d.rank_count( @population ) do |individual,rank,count| 
       individual.smartRank = rank 
       individual.smartCount = count
    end
  end
 
  def xtest_rank_count_proc
    d = Dominance.new( proc {|a,b| a.nondominance b } )
    rankedPopulation = d.rank_count @population
  end

  def xtest_rank_count_empty_population
  end

  def xtest_rank_count_small_population
  end
 
  def xtest_depth_basic
    d = Dominance.new
    rankedPopulation = d.depth @population
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

