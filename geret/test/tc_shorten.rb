#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/shorten'

include Operator

class TC_Shorten < Test::Unit::TestCase
  def test_deterministic
    s = Shorten.new
    assert_equal( false, s.stochastic )

    gen = [1, 2, 3, 4, 5, 6]
    assert_equal( [1, 2, 3], s.shorten(gen,3) )
    assert_equal( [1, 2, 3, 4, 5, 6], gen ) #clone test
    assert_equal( [1, 2, 3, 4, 5], s.shorten(gen,5) )
    assert_equal( [1, 2, 3, 4, 5, 6], gen ) #clone test
  
    assert_equal( gen, s.shorten(gen,50) ) #argument overflow
  end

  def test_stochastic
    s = Shorten.new
    s.stochastic = true
    assert_equal( true, s.stochastic )

    gen = [1, 2, 3, 4, 5, 6]
    s.random = MockRand.new [{4=>1}, {5=>3}]
    assert_equal( [1, 2, 3, 4], s.shorten(gen,3) )
    assert_equal( [1, 2, 3, 4, 5, 6], gen ) #clone test
    assert_equal( [1, 2, 3, 4, 5], s.shorten(gen,2) )
    assert_equal( [1, 2, 3, 4, 5, 6], gen ) #clone test
  
    assert_equal( gen, s.shorten(gen,50) ) #argument overflow
    assert( gen.object_id != s.shorten(gen,50).object_id ) #clone test
 end

end

