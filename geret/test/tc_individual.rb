#!/usr/bin/ruby

require 'test/unit'
require 'lib/individual'

class MockMapper
  def initialize
    @used_length = 5
  end

  def phenotype genotype 
    "some creative phenotype"
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
  end 

end

