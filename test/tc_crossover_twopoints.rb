
$LOAD_PATH << '.'

require 'test/unit'
require 'test/mock_rand'
require 'lib/crossover_twopoints'

include Operator

class TC_CrossoverTwoPoints < Test::Unit::TestCase

  def test_basics
    parent1 = [1, 2,    3, 4,    5]
    parent2 = [6,    7, 8, 9, 10,   11, 12]

    c = CrossoverTwoPoints.new
    c.random = MockRand.new [{6=>2}, {6=>4}, {8=>5}, {8=>1}]
    offspring1, offspring2 = c.crossover( parent1, parent2, nil, nil ) 

    assert_equal( [1, 2,   7, 8, 9, 10,    5 ], offspring1 )
    assert_equal( [6,   3, 4,   11, 12], offspring2 )   

    assert_equal( [1, 2, 3, 4, 5], parent1 )
    assert_equal( [6, 7, 8, 9, 10, 11, 12], parent2 ) 

    # repeat
    parent1 = [ 1,  2,  3,  4,  5,  6,  7,  8,  9,  10 ]
    parent2 = [ 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23 ]
    c.random = MockRand.new [{11=>2}, {11=>10}, {14=>10}, {14=>9}]
    offspring1, offspring2 = c.crossover( parent1, parent2, nil, nil ) 
    assert_equal( [ 1, 2,   20 ], offspring1 )
    assert_equal( [ 11, 12, 13, 14, 15, 16, 17, 18, 19,    3,  4,  5,  6,  7,  8,  9,  10,    21, 22, 23  ], offspring2 )   

  end

  def test_short
    parent1 = [1  ]
    parent2 = [6,    7, 8, 9, 10,   11, 12]

    c = CrossoverTwoPoints.new
    c.random = MockRand.new [{2=>1}, {2=>1}, {8=>5}, {8=>1}]
    offspring1, offspring2 = c.crossover( parent1, parent2, nil, nil ) 

    assert_equal( [1,   7, 8, 9, 10 ], offspring1 )
    assert_equal( [6,    11, 12], offspring2 )   

    assert_equal( [1], parent1 )
    assert_equal( [6, 7, 8, 9, 10, 11, 12], parent2 ) 
  end

  def test_empty
    parent1 = []
    parent2 = [6,    7, 8, 9, 10,   11, 12]

    c = CrossoverTwoPoints.new
    c.random = MockRand.new []
    offspring1, offspring2 = c.crossover( parent1, parent2, nil, nil ) 

    assert_equal( parent1, offspring1 )
    assert_equal( parent2, offspring2 )   

    assert_equal( [], parent1 )
    assert_equal( [6, 7, 8, 9, 10, 11, 12], parent2 ) 
  end

  def test_samepoint
    parent1 = [1,    2,    3, 4, 5]
    parent2 = [   6, 7, 8, 9, 10, 11, 12]

    c = CrossoverTwoPoints.new
    c.random = MockRand.new [{6=>2}, {6=>1}, {8=>0}, {8=>0}]
    offspring1, offspring2 = c.crossover( parent1, parent2, nil, nil ) 

    assert_equal( [1,   3, 4, 5], offspring1 )
    assert_equal( [2,   6, 7, 8, 9, 10, 11, 12], offspring2 )   

    assert_equal( [1, 2, 3, 4, 5], parent1 )
    assert_equal( [6, 7, 8, 9, 10, 11, 12], parent2 ) 
  end

end

