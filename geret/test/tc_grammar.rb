#!/usr/bin/ruby

require 'test/unit'
require 'lib/grammar'

include Mapper

class TC_Grammar < Test::Unit::TestCase

  def test_attributes
     grammar = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ Token.new( :literal, 'x', 42 ) ] )
                ] ),

       'op'  => Rule.new( [ 
                  RuleAlt.new( [ Token.new( :literal, '*' ) ] )
                ] )
    }, 'expr' )

    assert_equal( 'expr', grammar.start_symbol )
    grammar.start_symbol = 'op'
    assert_equal( 'op', grammar.start_symbol )

    assert_equal( 2, grammar.symbols.size )
    assert( grammar.symbols.include?( 'op' ) )
    assert( grammar.symbols.include?( 'expr' ) )   
  end

  def test_deep_copy
    grammar1 = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ Token.new( :symbol, 'op' ) ], :terminating )
                ], :cyclic ),

       'op'  => Rule.new( [ 
                  RuleAlt.new( [ Token.new( :symbol, 'expr', 42 ) ], :cyclic )
                ], :infinite )
    }, 'expr' )

    grammar2 = grammar1.deep_copy
    assert( grammar2.object_id != grammar1.object_id ) #different instances

    grammar1.start_symbol = 'op'
    assert_equal( 'expr', grammar2.start_symbol )

    grammar1['op'].first.push Token.new( :literal, '*' )
    assert_equal( 1, grammar2['op'].first.size )

    grammar1['op'].first.first.depth = 1
    assert_equal( 42, grammar2['op'].first.first.depth )   
    
    grammar1['expr'].first.first.type = :literal
    assert_equal( :symbol, grammar2['expr'].first.first.type )   

    grammar1['expr'].recursivity = :infinite
    assert_equal( :infinite, grammar1['expr'].recursivity )
    assert_equal( :cyclic, grammar2['expr'].recursivity )

    grammar1['expr'].first.recursivity = :cyclic
    assert_equal( :cyclic, grammar1['expr'].first.recursivity )
    assert_equal( :terminating, grammar2['expr'].first.recursivity )
 
  end
 
end

