#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/random_init'

class TC_RandomInit < Test::Unit::TestCase

  def test_basic
    init = RandomInit.new 10
    assert_equal( [10], init.magnitude )

    init.random =  MockRand.new [{10,3}, {10,0}, {10,8}, {10,5}]
    gen = init.init 4
    assert_equal( [3, 0, 8, 5], gen )
  end

  def test_triplets
    init = RandomInit.new [10, 2, 1000]
    assert_equal( [10, 2, 1000], init.magnitude )

    init.random =  MockRand.new [{10,8}, {2,0}, {1000,892}, {10,5}, {2,1}, {1000,403}, ]
    gen = init.init 7 # cropped to 6
    assert_equal( [8, 0, 892,  5, 1, 403], gen )
  end

end

