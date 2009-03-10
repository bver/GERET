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

  def  test_magnitude
    m = Mutation.new 100
    assert_equal( 100, m.magnitude )

    m.random = MockRand.new [{6,3}, {100,42}]
    orig = [1, 2, 3, 4, 5, 6]
    mutant = m.mutation orig
    assert_equal( [1, 2, 3, 42, 5, 6], mutant )
    assert_equal( [1, 2, 3, 4, 5, 6], orig ) 
   
    assert_equal( nil, Mutation.new.magnitude )
  end

end

