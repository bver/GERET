
$LOAD_PATH << '.'

require 'test/unit'
require 'test/mock_rand'
require 'lib/crossover_ripple'

include Operator

class TC_CrossoverRipple < Test::Unit::TestCase

  def test_basics
    parent1 = [1, 2,    3, 4, 5]
    parent2 = [6, 7, 8, 9, 10,   11, 12]

    c = CrossoverRipple.new
    c.random = MockRand.new [{6=>2}, {8=>5}]
    offspring1, offspring2 = c.crossover( parent1, parent2 ) 

    assert_equal( [1, 2, 11, 12], offspring1 )
    assert_equal( [6, 7, 8, 9, 10, 3, 4, 5], offspring2 )   

    assert_equal( [1, 2,    3, 4, 5], parent1 )
    assert_equal( [6, 7, 8, 9, 10,   11, 12], parent2 ) 
  end

  def test_short
    parent1 = [1  ]
    parent2 = [2, 3, 4, 5,    6, 7, 8, 9]

    c = CrossoverRipple.new
    c.random = MockRand.new [{2=>1}, {9=>4}]
    offspring1, offspring2 = c.crossover( parent1, parent2 ) 

    assert_equal( [1, 6, 7, 8, 9], offspring1 )
    assert_equal( [2, 3, 4, 5], offspring2 )   

    c.random = MockRand.new [{2=>0}, {9=>8}]
    offspring1, offspring2 = c.crossover( parent1, parent2 ) 

    assert_equal( [], offspring1 )
    assert_equal( [2, 3, 4, 5,    6, 7, 8, 9, 1], offspring2 )   
  end

  def test_margin
    parent1 = [1, 2, 3,   4, 5]
    parent2 = [6, 7, 8, 9,    10, 11, 12]

    c = CrossoverRipple.new
    c.random = MockRand.new [{2=>1}, {4=>2}]

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
    c.random = MockRand.new [{1=>0}, {2=>0}]      
   
    offspring1, offspring2 = c.crossover( parent1, parent2 )
    assert_equal( [1, 2, 3,  9, 10, 11, 12], offspring1 )
    assert_equal( [6, 7, 8,  4, 5, 6], offspring2 )   
  end

  def test_step
    parent1 = [1, 2,    3, 4, 5, 6]
    parent2 = [7, 8, 9, 10, 11, 12  ]

    c = CrossoverRipple.new
    r = MockRand.new [{4=>1}, {4=>3}]      
    c.random = r

    assert_equal( 0, c.margin )
    assert_equal( 1, c.step )
    c.step = 2
    assert_equal( 2, c.step )

    offspring1, offspring2 = c.crossover( parent1, parent2 ) 

    assert_equal( [1, 2], offspring1 )
    assert_equal( [7, 8, 9, 10, 11, 12, 3, 4, 5, 6], offspring2 )   
  end
  
  def test_step_margin
    parent1 = [1,    2, 3, 4, 5, 6]
    parent2 = [7, 8, 9,   10, 11, 12]

    c = CrossoverRipple.new
    r = MockRand.new [{3=>0}, {3=>1}]      
    c.random = r

    c.step = 2
    c.margin = 1
    offspring1, offspring2 = c.crossover( parent1, parent2 ) 

    assert_equal( [1, 10, 11, 12], offspring1 )
    assert_equal( [7, 8, 9, 2, 3, 4, 5, 6], offspring2 )   
  end
 
  def test_fixed
    parent1 = [1, 2,   3, 4, 5]
    parent2 = [6, 7, 8, 9, 10, 11,   12]

    c = CrossoverRipple.new
    assert_equal( false, c.fixed )
    c.fixed = true
    assert_equal( true, c.fixed )

    r = MockRand.new [{6=>2}]      
    c.random = r
    offspring1, offspring2 = c.crossover( parent1, parent2 ) 

    assert_equal( [1, 2, 8, 9, 10, 11, 12], offspring1 )
    assert_equal( [6, 7, 3, 4, 5], offspring2 )   

    parent1 = [6, 7, 8, 9, 10, 11,   12] 
    parent2 = [1, 2,   3, 4, 5]

    r = MockRand.new [{6=>2}]      
    c.random = r
    offspring1, offspring2 = c.crossover( parent1, parent2 ) 

    assert_equal( [6, 7, 3, 4, 5], offspring1 )
    assert_equal( [1, 2, 8, 9, 10, 11, 12], offspring2 )   
  end

  def test_step_margin_fixed
    parent1 = [1, 2, 3,   4, 5, 6]
    parent2 = [7, 8, 9,   10, 11]

    c = CrossoverRipple.new
    r = MockRand.new [{2=>1}]      
    c.random = r
    c.step = 2
    c.margin = 1
    c.fixed = true

    offspring1, offspring2 = c.crossover( parent1, parent2 ) 

    assert_equal( [1, 2, 3, 10, 11], offspring1 )
    assert_equal( [7, 8, 9, 4, 5, 6], offspring2 )   
  end

  def test_tolerance
    parent1 = [1]
    parent2 = [7, 8, 9, 10, 11]

    c = CrossoverRipple.new
    r = MockRand.new [{2=>1}]      
    c.random = r
    c.step = 2
    c.margin = 4
    c.fixed = true

    offspring1, offspring2 = c.crossover( parent1, parent2 ) 

    assert_equal( [1], offspring1 )
    assert_equal( [7, 8, 9, 10, 11], offspring2 )   

    assert_equal( true, c.tolerance )
    c.tolerance = false
    assert_equal( false, c.tolerance )

    exception = assert_raise( RuntimeError ) { c.crossover( parent1, parent2 ) }
    assert_equal( "CrossoverRipple: operand(s) too short", exception.message )
  end

  def test_extended_iface
    parent1 = [1, 2,    3, 4, 5]
    parent2 = [6, 7, 8, 9, 10,   11, 12]

    c = CrossoverRipple.new
    c.random = MockRand.new [{6=>2}, {8=>5}]

    c.crossover( parent1, parent2, nil, nil )   
  end
    
end

