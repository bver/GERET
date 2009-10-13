#!/usr/bin/ruby

require 'test/unit'
require 'lib/grammar'
require 'lib/validator'

include Mapper

class TC_Validator < Test::Unit::TestCase

  def setup
    @grammar1 = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ Token.new( :symbol, 'op' ) ] )
                ] ),

       'op'  => Rule.new( [ 
                  RuleAlt.new( [ Token.new( :symbol, 'expr' ) ] )
                ] )
    }, 'expr' )
  end

  def test_undefined_symbol

    assert_equal( [], Validator.check_undefined( @grammar1 ) )

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
   
    assert_equal( [], Validator.check_unused( @grammar1 ) )

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

  def test_trivial_infinite
    gram = Validator.analyze_recursivity @grammar1

    assert( gram.object_id != @grammar1.object_id ) #different instances, deep copy

    assert_equal( :infinite, gram['expr'].recursivity )
    assert_equal( :infinite, gram['op'].recursivity )
    assert_equal( :infinite, gram['expr'].first.recursivity )
    assert_equal( :infinite, gram['op'].first.recursivity )
  end

  def test_nontrivial_recursivity
    grammar = Grammar.new( { 
      'start' => Rule.new( [ 
                   RuleAlt.new( [ 
                     Token.new( :literal, 'one' ),
                     Token.new( :symbol, 'potential' ), 
                     Token.new( :literal, 'two' ),                   
                   ] ),
                   RuleAlt.new( [ 
                     Token.new( :symbol, 'loop1' ), 
                     Token.new( :literal, 'three' ),                   
                   ] ),
                 ] ),
      'potential' => Rule.new( [ 
                   RuleAlt.new( [ 
                     Token.new( :literal, 'one' ),
                     Token.new( :symbol, 'term1' ), 
                   ] ),
                   RuleAlt.new( [ 
                     Token.new( :symbol, 'term2' ), 
                     Token.new( :symbol, 'term1' ),                   
                   ] ),
                 ] ),                
      'term1' => Rule.new( [ 
                   RuleAlt.new( [ 
                     Token.new( :literal, 'TERM1' ),
                   ] ),
                 ] ),                
      'term2' => Rule.new( [ 
                   RuleAlt.new( [ 
                     Token.new( :literal, 'TERM2' ),
                   ] ),
                   RuleAlt.new( [ 
                     Token.new( :literal, 'TERM3' ),
                   ] ),
                 ] ),                
      'loop1' => Rule.new( [ 
                   RuleAlt.new( [ 
                     Token.new( :symbol, 'loop2' ), 
                     Token.new( :symbol, 'loop2' ),                   
                   ] ),
                 ] ),                
      'loop2' => Rule.new( [ 
                   RuleAlt.new( [ 
                     Token.new( :symbol, 'loop3' ), 
                   ] ),
                   RuleAlt.new( [ 
                     Token.new( :symbol, 'loop1' ),                   
                   ] ),
                 ] ),                
      'loop3' => Rule.new( [ 
                   RuleAlt.new( [ 
                     Token.new( :symbol, 'loop1' ), 
                   ] ),
                 ] ),                
     }, 'start' )
  
     gram = Validator.analyze_recursivity grammar 

     assert_equal( :cyclic, gram['start'].recursivity )
     assert_equal( :terminating, gram['start'][0].recursivity )
     assert_equal( :infinite, gram['start'][1].recursivity )   

     assert_equal( :terminating, gram['potential'].recursivity )
     assert_equal( :terminating, gram['potential'][0].recursivity )
     assert_equal( :terminating, gram['potential'][1].recursivity )   

     assert_equal( :terminating, gram['term1'].recursivity )
     assert_equal( :terminating, gram['term1'][0].recursivity )
  
     assert_equal( :terminating, gram['term2'].recursivity )
     assert_equal( :terminating, gram['term2'][0].recursivity )
     assert_equal( :terminating, gram['term2'][1].recursivity )   

     assert_equal( :infinite, gram['loop1'].recursivity )
     assert_equal( :infinite, gram['loop1'][0].recursivity )

     assert_equal( :infinite, gram['loop2'].recursivity )
     assert_equal( :infinite, gram['loop2'][0].recursivity )
     assert_equal( :infinite, gram['loop2'][1].recursivity )   

     assert_equal( :infinite, gram['loop3'].recursivity )
     assert_equal( :infinite, gram['loop3'][0].recursivity )

     ###
     
     grammar['loop3'].push RuleAlt.new( [ Token.new( :symbol, 'potential' ) ] )

     gram = Validator.analyze_recursivity grammar

     assert_equal( :cyclic, gram['start'].recursivity )
     assert_equal( :terminating, gram['start'][0].recursivity )
     assert_equal( :cyclic, gram['start'][1].recursivity )   

     assert_equal( :terminating, gram['potential'].recursivity )
     assert_equal( :terminating, gram['potential'][0].recursivity )
     assert_equal( :terminating, gram['potential'][1].recursivity )   

     assert_equal( :terminating, gram['term1'].recursivity )
     assert_equal( :terminating, gram['term1'][0].recursivity )
  
     assert_equal( :terminating, gram['term2'].recursivity )
     assert_equal( :terminating, gram['term2'][0].recursivity )
     assert_equal( :terminating, gram['term2'][1].recursivity )   

     assert_equal( :cyclic, gram['loop1'].recursivity )
     assert_equal( :cyclic, gram['loop1'][0].recursivity )

     assert_equal( :cyclic, gram['loop2'].recursivity )
     assert_equal( :cyclic, gram['loop2'][0].recursivity )
     assert_equal( :cyclic, gram['loop2'][1].recursivity )   

     assert_equal( :cyclic, gram['loop3'].recursivity )
     assert_equal( :cyclic, gram['loop3'][0].recursivity )
     assert_equal( :terminating, gram['loop3'][1].recursivity ) 
  end

  def test_structural_nodal_support
    grammar = Grammar.new( { 
      'start' => Rule.new( [   # nodal
                   RuleAlt.new( [ 
                     Token.new( :literal, 'one' ),
                     Token.new( :symbol, 'potential' ), 
                     Token.new( :literal, 'two' ),                   
                   ] ),
                   RuleAlt.new( [ 
                     Token.new( :symbol, 'potential' ), 
                     Token.new( :literal, 'three' ),                   
                   ] ),
                 ] ),
      'potential' => Rule.new( [ # structural 
                   RuleAlt.new( [  
                     Token.new( :literal, 'one' ),
                     Token.new( :symbol, 'term1' ), 
                   ] ),
                   RuleAlt.new( [ 
                     Token.new( :symbol, 'term2' ), 
                     Token.new( :symbol, 'term1' ),                   
                   ] ),
                 ] ),                
      'term1' => Rule.new( [ # nodal 
                   RuleAlt.new( [ 
                     Token.new( :literal, 'TERM1' ),
                   ] ),
                 ] ),                
      'term2' => Rule.new( [ # nodal 
                   RuleAlt.new( [  
                     Token.new( :literal, 'TERM2' ),
                   ] ),
                   RuleAlt.new( [ 
                     Token.new( :literal, 'TERM3' ),
                     Token.new( :literal, 'TERM1' ),                    
                   ] ),
                 ] ),                
      'loop1' => Rule.new( [  # nodal
                   RuleAlt.new( [
                     Token.new( :symbol, 'loop2' ), 
                     Token.new( :symbol, 'loop2' ),                   
                   ] ),
                 ] ),                
      'loop2' => Rule.new( [ # structural 
                   RuleAlt.new( [ 
                     Token.new( :symbol, 'loop3' ), 
                   ] ),
                   RuleAlt.new( [ 
                     Token.new( :symbol, 'loop1' ),                   
                   ] ),
                 ] ),                
      'loop3' => Rule.new( [  # nodal
                   RuleAlt.new( [ 
                      Token.new( :literal, 'TERM3' ),
                      Token.new( :symbol, 'loop1' ), 
                   ] ),
                   RuleAlt.new( [ 
                     Token.new( :symbol, 'loop1' ), 
                   ] ),
                   RuleAlt.new( [ 
                     Token.new( :symbol, 'loop1' ), 
                     Token.new( :literal, 'TERM' ),                    
                   ] ),
                
                 ] ),                
     }, 'start' )
   
     Validator.analyze_sn_altering grammar

     assert_equal( :nodal, grammar[ 'start' ].sn_altering )
     assert_equal( :structural, grammar[ 'potential' ].sn_altering ) 
     assert_equal( :nodal, grammar[ 'term1' ].sn_altering )    
     assert_equal( :nodal, grammar[ 'term2' ].sn_altering )    
     assert_equal( :nodal, grammar[ 'loop1' ].sn_altering )       
     assert_equal( :structural, grammar[ 'loop2' ].sn_altering )   
     assert_equal( :nodal, grammar[ 'loop3' ].sn_altering )      
  end
end

