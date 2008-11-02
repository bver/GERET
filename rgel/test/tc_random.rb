#!/usr/bin/ruby

require 'test/unit'
require 'lib/random'

class TC_Random < Test::Unit::TestCase
  def setup
  end

  def test_deterministic
    r = Random.new :deterministic
    r.set [3, 0.15, 1000, 42]
    assert_equal( 3, r.rand(10) )
    assert_equal( 0.15, r.rand )
    assert_equal( 1000, r.rand(2000) )

    r.set [15, 0.5, 1000, 42]
    assert_equal( 42, r.rand(2000) )
    assert_equal( 15, r.rand(100) )   
    assert_equal( 0.15, r.rand )   
  end

  def test_repeatable
    r1 = Random.new :repeatable
    results = []
    1000.times { results.push r1.rand(1000) }

    r2 = Random.new :repeatable
    results.each |x| do
      assert( x<1000 )
      assert_equal( x, r2.rand(1000) )
    end
  end

  def test_stochastic
    r = Random.new :stochastic
    1000.times do
      assert( r.rand(1000)<1000 )
      assert( r.rand < 1.0 )
    end
  end

  def test_mode_not_supported
    exception = assert_raise( RuntimeError ) { r = Random.new :nonsense }
    assert_equal( "Random: mode not supported", exception.message )
  end

  def test_set_missing
    r = Random.new :deterministic
    exception = assert_raise( RuntimeError ) { r.rand } 
    assert_equal( "Random: set() in :deterministic mode not called", exception.message )   
  end

  def test_set_overrun
    r = Random.new :deterministic
    r.set [3, 0.15]
    assert_equal( 3, r.rand(10) )
    assert_equal( 0.15, r.rand )      
    exception = assert_raise( RuntimeError ) { r.rand } 
    assert_equal( "Random: shortage of :deterministic values", exception.message )    
  end

end

