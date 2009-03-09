#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/crossover'

class TC_Crossover < Test::Unit::TestCase

  def test_basics
    parent1 = [1, 2,    3, 4, 5]
    parent2 = [6, 7, 8, 9, 10,   11, 12]

    c = Crossover.new
    r = MockRand.new [{6,2}, {8,5}]      
    c.random = r
    offspring1, offspring2 = c.crossover( parent1, parent2 ) 

    assert_equal( [1, 2, 11, 12], offspring1 )
    assert_equal( [6, 7, 8, 9, 10, 3, 4, 5], offspring2 )   

    assert_equal( [1, 2,    3, 4, 5], parent1 )
    assert_equal( [6, 7, 8, 9, 10,   11, 12], parent2 ) 
  end

  def test_short
    parent1 = [1  ]
    parent2 = [2, 3, 4, 5,    6, 7, 8, 9]

    c = Crossover.new
    r = MockRand.new [{2,1}, {9,4}]      
    c.random = r
    offspring1, offspring2 = c.crossover( parent1, parent2 ) 

    assert_equal( [1, 6, 7, 8, 9], offspring1 )
    assert_equal( [2, 3, 4, 5], offspring2 )   

    r = MockRand.new [{2,0}, {9,8}]      
    c.random = r
    offspring1, offspring2 = c.crossover( parent1, parent2 ) 

    assert_equal( [], offspring1 )
    assert_equal( [2, 3, 4, 5,    6, 7, 8, 9, 1], offspring2 )   
  end

  def test_margin
    parent1 = [1, 2, 3,   4, 5]
    parent2 = [6, 7, 8, 9,    10, 11, 12]

    c = Crossover.new
    c.random = MockRand.new [{2,1}, {4,2}]

    assert_equal( 0, c.margin )
    c.margin = 2
    assert_equal( 2, c.margin )

    offspring1, offspring2 = c.crossover( parent1, parent2 ) 

    assert_equal( [1, 2, 3, 10, 11, 12], offspring1 )
    assert_equal( [6, 7, 8, 9, 4, 5], offspring2 )   

    c.random =MockRand.new []

    c.margin = 3
    assert_equal( 3, c.margin )

    offspring1, offspring2 = c.crossover( parent1, parent2 ) 
    assert_equal( parent1, offspring1 )
    assert_equal( parent2, offspring2 )

    parent1 = [1, 2, 3,   4, 5, 6]
    c.random = MockRand.new [{1,0}, {2,0}]      
   
    offspring1, offspring2 = c.crossover( parent1, parent2 )
    assert_equal( [1, 2, 3,  9, 10, 11, 12], offspring1 )
    assert_equal( [6, 7, 8,  4, 5, 6], offspring2 )   

  end
 
 
end

