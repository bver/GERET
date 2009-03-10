#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/mutation'

class TC_Mutation < Test::Unit::TestCase

  def test_basic
    m = Mutation.new
    m.random = MockRand.new [{6,3}, {7,2}]
    orig = [1, 2, 3, 4, 5, 6]
    mutant = m.mutation orig
    assert_equal( [1, 2, 3, 2, 5, 6], mutant )
    assert_equal( [1, 2, 3, 4, 5, 6], orig ) 
  end
  
end

