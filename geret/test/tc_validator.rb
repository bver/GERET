#!/usr/bin/ruby

require 'test/unit'
require 'lib/grammar'
require 'lib/validator'

include Mapper

class TC_Validator < Test::Unit::TestCase

  def test_undefined_symbol

    grammar1 = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ Token.new( :symbol, 'op' ) ] )
                ] ),

       'op'  => Rule.new( [ 
                  RuleAlt.new( [ Token.new( :symbol, 'expr' ) ] )
                ] )
    }, 'expr' )

  
    assert_equal( [], Validator.check_undefined( grammar1 ) )

    grammar2 = Grammar.new( { 
      'foo' => Rule.new( [ 
                 RuleAlt.new( [ 
                    Token.new( :symbol, '_foo_opt1' ),
                    Token.new( :symbol, 'unknown1' ) 
                 ] )
               ] ),

      '_foo_opt1' => Rule.new( [ 
                      RuleAlt.new( [ 
                        Token.new( :literal, 'bar' ) 
                      ] ),                            
                      RuleAlt.new( [ 
                        Token.new( :symbol, 'unk2' ),
                        Token.new( :literal, 'xyz' ) 
                      ] )
                    ] )
    }, 'foo' )
   
    undefineds = Validator.check_undefined( grammar2 )
 
    assert_equal( 2, undefineds.size )
    assert( undefineds.include?( 'unknown1' ) )
    assert( undefineds.include?( 'unk2'  ) )

  end

  def test_unused_symbol

    grammar1 = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ Token.new( :symbol, 'op' ) ] )
                ] ),

       'op'  => Rule.new( [ 
                  RuleAlt.new( [ Token.new( :symbol, 'expr' ) ] )
                ] )
    }, 'expr' )

   
    assert_equal( [], Validator.check_unused( grammar1 ) )

    grammar2 = Grammar.new( { 
      'foo' => Rule.new( [ 
                 RuleAlt.new( [ 
                    Token.new( :literal, 'one' ),
                    Token.new( :symbol, 'foo1' ) 
                 ] )
               ] ),

      'foo1' => Rule.new( [ 
                      RuleAlt.new( [ 
                        Token.new( :literal, 'bar' ) 
                      ] ),                            
                    ] ),
      'bar1' => Rule.new( [ 
                      RuleAlt.new( [ 
                        Token.new( :literal, 'bar' ) 
                      ] ),                            
                    ] ),
    }, 'foo' )
   
    unused = Validator.check_unused( grammar2 )
 
    assert_equal( 2, unused.size )
    assert( unused.include?( 'foo' ) )
    assert( unused.include?( 'bar1'  ) )

  end

 
end

