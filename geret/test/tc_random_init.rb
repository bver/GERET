#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/random_init'

class TC_RandomInit < Test::Unit::TestCase

  def test_basic
    init = RandomInit.new 10
    assert_equal( 10, init.magnitude )

    init.random =  MockRand.new [{10,3}, {10,0}, {10,8}, {10,5}]
    gen = init.init 4
    assert_equal( [3, 0, 8, 5], gen )
  end

end

