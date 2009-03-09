#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/crossover'

class TC_Crossover < Test::Unit::TestCase

  def test_basics
    parent1 = [1, 2,    3, 4, 5]
    parent2 = [6, 7, 8, 9, 10,   11, 12]

    ops = GenOps.new
    r = MockRand.new [{6,2}, {8,5}]      
    ops.random = r
    offspring1, offspring2 = ops.crossover( parent1, parent2 ) 

    assert_equal( [1, 2, 11, 12], offspring1 )
    assert_equal( [6, 7, 8, 9, 10, 3, 4, 5], offspring2 )   

    assert_equal( [1, 2,    3, 4, 5], parent1 )
    assert_equal( [6, 7, 8, 9, 10,   11, 12], parent2 ) 
  end

  def test_short
    parent1 = [1  ]
    parent2 = [2, 3, 4, 5,    6, 7, 8, 9]

    ops = GenOps.new
    r = MockRand.new [{2,1}, {9,4}]      
    ops.random = r
    offspring1, offspring2 = ops.crossover( parent1, parent2 ) 

    assert_equal( [1, 6, 7, 8, 9], offspring1 )
    assert_equal( [2, 3, 4, 5], offspring2 )   

    r = MockRand.new [{2,0}, {9,8}]      
    ops.random = r
    offspring1, offspring2 = ops.crossover( parent1, parent2 ) 

    assert_equal( [], offspring1 )
    assert_equal( [2, 3, 4, 5,    6, 7, 8, 9, 1], offspring2 )   
  end

 
end

