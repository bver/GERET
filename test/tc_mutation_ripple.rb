
$LOAD_PATH << '.' unless $LOAD_PATH.include? '.'

require 'test/unit'
require 'test/mock_rand'
require 'lib/mutation_ripple'

include Operator

class TC_MutationRipple < Test::Unit::TestCase

  def test_bit_basic
    m = MutationBitRipple.new
    assert_equal( 8, m.codon.bit_size )
    m.random = MockRand.new [{6=>3}, {8=>1}]
    orig = [1, 2, 3, 4, 5, 6]
    mutant = m.mutation( orig, nil )
    assert_equal( [1, 2, 3, 6, 5, 6], mutant )
    assert_equal( [1, 2, 3, 4, 5, 6], orig ) 
  end

  def  test_bit_codon
    m = MutationBitRipple.new nil
    m.codon = Mapper::CodonMod.new(5)
    assert_equal( 5, m.codon.bit_size )   

    m.random = MockRand.new [{6=>2}, {5=>4}]
    orig = [1, 2, 3, 4, 5, 6]
    mutant = m.mutation orig
    assert_equal( [1, 2, 19, 4, 5, 6], mutant )
    assert_equal( [1, 2, 3, 4, 5, 6], orig ) 
  end

  def test_basic
    m = MutationRipple.new
    m.random = MockRand.new [{6=>3}, {7=>2}]
    orig = [1, 2, 3, 4, 5, 6]
    mutant = m.mutation( orig, nil )
    assert_equal( [1, 2, 3, 2, 5, 6], mutant )
    assert_equal( [1, 2, 3, 4, 5, 6], orig ) 
  end

  def  test_magnitude
    m = MutationRipple.new nil, 40
    assert_equal( 40, m.magnitude )
    m.magnitude = 100
    assert_equal( 100, m.magnitude )   

    m.random = MockRand.new [{6=>3}, {100=>42}]
    orig = [1, 2, 3, 4, 5, 6]
    mutant = m.mutation orig
    assert_equal( [1, 2, 3, 42, 5, 6], mutant )
    assert_equal( [1, 2, 3, 4, 5, 6], orig ) 
   
    assert_equal( nil, MutationRipple.new.magnitude )
  end

end

