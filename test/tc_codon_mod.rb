#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/codon_mod'

class TC_CodonMod < Test::Unit::TestCase

  def test_basic
    c = Mapper::CodonMod.new
    assert_equal( 8, c.bit_size ) #default

    assert_equal( 2, c.interpret( 3, 5 ) )
    assert_equal( 1, c.interpret( 2, 7 ) )

    assert( c.random.kind_of? Kernel ) #default is Kernel.rand
    c.random = MockRand.new [ {85=>1}, {85=>2}, {85=>84} ]

    assert_equal( 5, c.generate( 3, 2 ) )
    assert_equal( 8, c.generate( 3, 2 ) )   
    assert_equal( 2, c.generate( 0, 2 ) ) # do not call @random.rand
    assert_equal( 254, c.generate( 3, 2 ) )   
  end

  def test_bitsize
    c = Mapper::CodonMod.new(33)
    assert_equal( 33, c.bit_size )
    assert_equal( true, c.valid_codon?(255) )   

    c.bit_size = 5
    assert_equal( 5, c.bit_size )
    assert_equal( true, c.valid_codon?(31) )
    assert_equal( false, c.valid_codon?(-1) )   
    assert_equal( false, c.valid_codon?(255) )   
   
    c.random = MockRand.new [ {10=>1}, {10=>2}, {10=>9}, {1=>0} ]

    assert_equal( 5, c.generate( 3, 2 ) )
    assert_equal( 8, c.generate( 3, 2 ) )   
    assert_equal( 29, c.generate( 3, 2 ) )

    assert_equal( 13, c.generate( 28, 13 ) )   
  end

  def test_mutate
    c = Mapper::CodonMod.new   
    c.random = MockRand.new [ {8=>1} ]   
    assert_equal( 7, c.mutate_bit( 5 ) )
  end

end

