#!/usr/bin/ruby

require 'test/unit'
require 'lib/evaluator'

class TC_Evaluator < Test::Unit::TestCase
  def test_basic
     engine = Evaluator.new

     code = "[x + y * z, x * z]" 
     engine.code = code
     assert_equal( code, engine.code )
     
     result = engine.run( :x=>2, :y=>3, :z=>4 )
     assert_equal( [14,8], result )

     result = engine.run( :y=>3, :x=>3, :z=>1 )
     assert_equal( [6,3], result )

     code2 = '[x + y]'
     engine.code = code2
     assert_equal( code2, engine.code )

     result = engine.run( :y=>2, :x=>3, :z=>4 ) 
     assert_equal( [5], result )

     engine.code = 'input.size'
     result = engine.run( :input => [2,2,2,2] ) 
     assert_equal( 4, result )
  end

  def test_no_code
     engine = Evaluator.new
     assert_equal( nil, engine.code )
     exception = assert_raise( RuntimeError ) { engine.run( :y=>2, :x=>3, :z=>4 ) }
     assert_equal( "Evaluator: no code supplied", exception.message )
  end

  def test_caught_exception
    engine = Evaluator.new
    engine.code = "x/0" 
    result = engine.run( 'x'=>1 )
    assert_equal( nil, result )
  end

end

