
$LOAD_PATH << '.'

require 'test/unit'
require 'test/mock_rand'

class TC_Random < Test::Unit::TestCase

  def test_basics
    r = MockRand.new [3, 0.15, 1000, 42, 5555]
    assert_equal( [3, 0.15, 1000, 42, 5555], r.predef )

    assert_equal( 3, r.rand(10) )
    assert_equal( 0.15, r.rand )
    assert_equal( 1000, r.rand(2000) )

    assert_equal( [42, 5555], r.predef )
  end

  def test_no_data
    r = MockRand.new
    exception = assert_raise( RuntimeError ) { r.rand } 
    assert_equal( "MockRand: shortage of values", exception.message )

    r = MockRand.new []
    exception = assert_raise( RuntimeError ) { r.rand } 
    assert_equal( "MockRand: shortage of values", exception.message )
  end

  def test_accessor
    r = MockRand.new  
    assert_equal( [], r.predef )
    r.predef = [15, 0.55, 1000]
    assert_equal( [15, 0.55, 1000], r.predef )

    assert_equal( 15, r.rand(100) )   
    assert_equal( 0.55, r.rand )   
  end

  def test_set_overrun
    r = MockRand.new [3, 0.15]
    assert_equal( 3, r.rand(10) )
    assert_equal( 0.15, r.rand )      
    exception = assert_raise( RuntimeError ) { r.rand } 
    assert_equal( "MockRand: shortage of values", exception.message )    
  end

  def test_set_exceeded
    r = MockRand.new [3, 0.15]
    exception = assert_raise( RuntimeError ) { r.rand(1) } 
    assert_equal( "MockRand: value exceeded", exception.message )  
  end

  def test_hashes
    r = MockRand.new [{4=>1}, 2, {3=>2}]
    assert_equal( 1, r.rand(4) )
    assert_equal( [2, {3=>2}], r.predef ) 
    assert_equal( 2, r.rand(4) )
    assert_equal( [{3=>2}], r.predef )  
    assert_equal( 2, r.rand(3) )
    assert_equal( [], r.predef )  
  end

  def test_alternatives
    vals = [{3=>2, 2=>0, 0=>0.33}]
    r = MockRand.new vals.clone
    assert_equal( 0, r.rand(2) ) 
    r.predef = vals.clone
    assert_equal( 2, r.rand(3) ) 
    r.predef = vals.clone
    assert_equal( 0.33, r.rand ) 
  end

  def test_unexpected_args
    r = MockRand.new [{3=>2, 2=>0}]
    exception = assert_raise( RuntimeError ) { r.rand(1) } 
    assert_equal( "MockRand: unexpected argument (1), expected (2, 3) remaining=0", exception.message )  
  end

end

