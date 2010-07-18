#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/mutation_ripple'

include Operator

class TC_MutationRipple < Test::Unit::TestCase

  def test_basic
    m = MutationRipple.new
    assert_equal( 8, m.codon.bit_size )
    m.random = MockRand.new [{6=>3}, {8=>1}]
    orig = [1, 2, 3, 4, 5, 6]
    mutant = m.mutation( orig, nil )
    assert_equal( [1, 2, 3, 6, 5, 6], mutant )
    assert_equal( [1, 2, 3, 4, 5, 6], orig ) 
  end

  def  test_codon
    m = MutationRipple.new nil
    m.codon = Mapper::CodonMod.new(5)
    assert_equal( 5, m.codon.bit_size )   

    m.random = MockRand.new [{6=>2}, {5=>4}]
    orig = [1, 2, 3, 4, 5, 6]
    mutant = m.mutation orig
    assert_equal( [1, 2, 19, 4, 5, 6], mutant )
    assert_equal( [1, 2, 3, 4, 5, 6], orig ) 
  end

end

