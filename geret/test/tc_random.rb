#!/usr/bin/ruby

require 'test/unit'
require 'lib/random'

class TC_Random < Test::Unit::TestCase

  def setup
  end

  def test_deterministic
    r = Random.new :deterministic
    assert_equal( :deterministic, r.mode )
    assert_equal( nil, r.predef ) 
    r.set_predef [3, 0.15, 1000, 42, 5555]
    assert_equal( [3, 0.15, 1000, 42, 5555], r.predef )

    assert_equal( 3, r.rand(10) )
    assert_equal( 0.15, r.rand )
    assert_equal( 1000, r.rand(2000) )

    assert_equal( [42, 5555], r.predef )
    r.set_predef [15, 0.55, 1000]
    assert_equal( 15, r.rand(100) )   
    assert_equal( 0.55, r.rand )   
  end

  def test_repeatable
    r1 = Random.new :repeatable
    assert_equal( :repeatable, r1.mode )   
    results = []
    1000.times { results.push r1.rand(1000) }

    r2 = Random.new :repeatable
    results.each do |x| 
      assert( x<1000 )
      assert_equal( x, r2.rand(1000) )
    end
  end

  def test_stochastic
    r = Random.new :stochastic
    assert_equal( :stochastic, r.mode ) 
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
    assert_equal( "Random: set_predef() in :deterministic mode not called", exception.message )   
  end

  def test_set_overrun
    r = Random.new :deterministic
    r.set_predef [3, 0.15]
    assert_equal( 3, r.rand(10) )
    assert_equal( 0.15, r.rand )      
    exception = assert_raise( RuntimeError ) { r.rand } 
    assert_equal( "Random: shortage of :deterministic values", exception.message )    
  end

  def test_set_exceeded
    r = Random.new :deterministic
    r.set_predef [3, 0.15]
    exception = assert_raise( RuntimeError ) { r.rand(1) } 
    assert_equal( "Random: :deterministic value exceeded", exception.message )  
  
    r = Random.new :deterministic
    r.set_predef [3, 0.15]
    exception = assert_raise( RuntimeError ) { r.rand } 
    assert_equal( "Random: :deterministic value exceeded", exception.message )  
  end

  def test_set_in_wrong_mode
    r = Random.new :stochastic 
    exception = assert_raise( RuntimeError ) { r.set_predef [42, 3] }
    assert_equal( "Random: calling set_predef in wrong mode", exception.message )

    r = Random.new :repeatable 
    exception = assert_raise( RuntimeError ) { r.set_predef [42, 3] }
    assert_equal( "Random: calling set_predef in wrong mode", exception.message )
  end

end

