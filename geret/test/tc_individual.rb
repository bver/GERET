#!/usr/bin/ruby

require 'test/unit'
require 'lib/individual'

include Util

class MockMapper
  def initialize
    @used_length = 5
  end

  def phenotype genotype 
    genotype.size > 3 ? "some creative phenotype" : nil
  end

  attr_reader :used_length
end

class TC_Individual < Test::Unit::TestCase
  
  def setup
    @mapper = MockMapper.new
  end

  def test_basic
    individual = Individual.new( @mapper, [1, 2, 3, 4, 5, 6, 7]  )
    assert_equal( [1, 2, 3, 4, 5, 6, 7], individual.genotype )
    assert_equal( "some creative phenotype", individual.phenotype )
    assert_equal( 5, individual.used_length )
    assert_equal( true, individual.valid? )

    individual.shorten_chromozome = false
    assert_equal( [1, 2, 3, 4, 5, 6, 7], individual.genotype )
    individual.shorten_chromozome = true
    assert_equal( [1, 2, 3, 4, 5], individual.genotype )
  end 

  def test_invalid
    individual = Individual.new( @mapper, [1, 2]  )
    assert_equal( [1, 2], individual.genotype )
    assert_equal( nil, individual.phenotype )
    assert_equal( false, individual.valid? )
  end

end

