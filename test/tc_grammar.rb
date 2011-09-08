
$LOAD_PATH << '.'

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
                  RuleAlt.new( [ Token.new( :symbol, 'op' ) ], :terminating, 12 )
                ], :cyclic, :structural ),

       'op'  => Rule.new( [ 
                  RuleAlt.new( [ Token.new( :symbol, 'expr', 42 ) ], :cyclic, 33, 88 )
                ], :infinite, :nodal, 99 )
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

    grammar1['expr'].first.arity = 11
    assert_equal( 12, grammar2['expr'].first.arity )   
    grammar1['op'].first.arity = 1
    grammar1['op'].first.min_depth = 3      
    assert_equal( 33, grammar2['op'].first.arity )   
    assert_equal( 88, grammar2['op'].first.min_depth )

    grammar1['expr'].sn_altering = :nodal
    assert_equal( :nodal, grammar1['expr'].sn_altering )
    assert_equal( :structural, grammar2['expr'].sn_altering )

    grammar1['op'].sn_altering = :structural
    grammar1['op'].min_depth = 23
    assert_equal( :structural, grammar1['op'].sn_altering )
    assert_equal( :nodal, grammar2['op'].sn_altering )
    assert_equal( 99, grammar2['op'].min_depth )   
  
  end
 
end

