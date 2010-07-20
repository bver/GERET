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

    @grammar2 = Grammar.new( { 
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
    
    @gram_sn_a = Grammar.new( { 
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
   
  end

  def test_undefined_symbol

    assert_equal( [], Validator.check_undefined( @grammar1 ) )

  
    undefineds = Validator.check_undefined @grammar2
 
    assert_equal( 2, undefineds.size )
    assert( undefineds.include?( 'unknown1' ) )
    assert( undefineds.include?( 'unk2'  ) )

  end

  def test_recursivity_over_undefined
    exception = assert_raise( RuntimeError ) { Validator.analyze_recursivity @grammar2 }
    assert_equal( "Validator: cannot analyze_recursivity of undefined symbols", exception.message )
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
    gram = @grammar1.deep_copy
    assert( gram.object_id != @grammar1.object_id ) #different instances, deep copy

    Validator.analyze_recursivity gram
   
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
   
     Validator.analyze_sn_altering @gram_sn_a

     assert_equal( :nodal, @gram_sn_a[ 'start' ].sn_altering )
     assert_equal( :structural, @gram_sn_a[ 'potential' ].sn_altering ) 
     assert_equal( :nodal, @gram_sn_a[ 'term1' ].sn_altering )    
     assert_equal( :nodal, @gram_sn_a[ 'term2' ].sn_altering )    
     assert_equal( :nodal, @gram_sn_a[ 'loop1' ].sn_altering )       
     assert_equal( :structural, @gram_sn_a[ 'loop2' ].sn_altering )   
     assert_equal( :nodal, @gram_sn_a[ 'loop3' ].sn_altering )      
  end

  def test_analyze_arity

     Validator.analyze_arity @gram_sn_a

     assert_equal( 1, @gram_sn_a['start'][0].arity )
     assert_equal( 1, @gram_sn_a['start'][1].arity )    
     assert_equal( 1, @gram_sn_a['potential'][0].arity )
     assert_equal( 2, @gram_sn_a['potential'][1].arity )    
     assert_equal( 0, @gram_sn_a['term1'][0].arity )
     assert_equal( 0, @gram_sn_a['term2'][0].arity )
     assert_equal( 0, @gram_sn_a['term2'][1].arity )
     assert_equal( 2, @gram_sn_a['loop1'][0].arity )   
     assert_equal( 1, @gram_sn_a['loop2'][0].arity )   
     assert_equal( 1, @gram_sn_a['loop2'][1].arity )   
     assert_equal( 1, @gram_sn_a['loop3'][0].arity )   
     assert_equal( 1, @gram_sn_a['loop3'][1].arity )   
     assert_equal( 1, @gram_sn_a['loop3'][2].arity )  

  end

  def test_analyze_min_depth_1
    grammar = Mapper::Grammar.new( { 
      'expr' => Mapper::Rule.new( [ # min_depth=2
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'x' ) ] ), # min_depth=1 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'y' ) ] ), # min_depth=1 
                  Mapper::RuleAlt.new( [ # min_depth=2 
                    Mapper::Token.new( :literal, '(' ), 
                    Mapper::Token.new( :symbol, 'expr' ), # min_depth=2 
                    Mapper::Token.new( :literal, ' ' ),                   
                    Mapper::Token.new( :symbol, 'aop' ),  # min_depth=2                
                    Mapper::Token.new( :symbol, 'expr' ), # min_depth=2                  
                    Mapper::Token.new( :literal, ')' ) 
                  ] )
                ] ),

       'aop'  => Mapper::Rule.new( [ # min_depth=2 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '+' ) ] ), # min_depth=1
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '*' ) ] ) # min_depth=1 
                ] )
    }, 'expr' )

    gram = Validator.analyze_min_depth grammar   

    assert_equal( 2, gram['expr'].min_depth )
    assert_equal( 3, gram['expr'].size )
    assert_equal( 1, gram['expr'][0].min_depth )
    assert_equal( 1, gram['expr'][1].min_depth )
    assert_equal( 2, gram['expr'][2].min_depth )   

    assert_equal( 2, gram['aop'].min_depth )   
    assert_equal( 2, gram['aop'].size )   
    assert_equal( 1, gram['aop'][0].min_depth )
    assert_equal( 1, gram['aop'][0].min_depth )   
  end

  def test_analyze_min_depth_2
    grammar = Grammar.new( { 
      'start' => Rule.new( [ # min_depth=4
                   RuleAlt.new( [ # min_depth=3 
                     Token.new( :literal, 'one' ),
                     Token.new( :symbol, 'potential' ), 
                     Token.new( :literal, 'two' ),                   
                   ] ),
                   RuleAlt.new( [ # min_depth=6 
                     Token.new( :symbol, 'loop1' ), 
                     Token.new( :literal, 'three' ),                   
                   ] ),
                 ] ),
      'potential' => Rule.new( [ # min_depth=3 
                   RuleAlt.new( [ # min_depth=2 
                     Token.new( :literal, 'one' ),
                     Token.new( :symbol, 'term1' ), 
                   ] ),
                   RuleAlt.new( [ # min_depth=2 
                     Token.new( :symbol, 'term2' ), 
                     Token.new( :symbol, 'term1' ),                   
                   ] ),
                 ] ),                
      'term1' => Rule.new( [  # min_depth=2 
                   RuleAlt.new( [ # min_depth=1 
                     Token.new( :literal, 'T1' ),
                   ] ),
                 ] ),                
      'term2' => Rule.new( [ # min_depth=2 
                   RuleAlt.new( [ # min_depth=1 
                     Token.new( :literal, 'T2A' ),
                   ] ),
                   RuleAlt.new( [ # min_depth=1 
                     Token.new( :literal, 'T2B' ),
                   ] ),
                 ] ),                
      'loop1' => Rule.new( [ # min_depth=6
                   RuleAlt.new( [ # min_depth=5 
                     Token.new( :symbol, 'loop3' ), 
                     Token.new( :symbol, 'loop2' ),                   
                   ] ),
                 ] ),                
      'loop2' => Rule.new( [ # min_depth=5 
                   RuleAlt.new( [ # min_depth=4 
                     Token.new( :symbol, 'loop3' ), 
                   ] ),
                   RuleAlt.new( [ # min_depth=6 
                     Token.new( :symbol, 'loop1' ),                   
                   ] ),
                 ] ),                
      'loop3' => Rule.new( [ # min_depth=4 
                   RuleAlt.new( [ # min_depth=3 
                     Token.new( :symbol, 'potential' ), 
                   ] ),
                   RuleAlt.new( [ # min_depth=6 
                     Token.new( :symbol, 'loop1' ), 
                   ] ),
                 ] ),                
     }, 'start' )
    
     gram = Validator.analyze_min_depth grammar   

     assert_equal( 4, gram['start'].min_depth )
     assert_equal( 2, gram['start'].size )
     assert_equal( 3, gram['start'][0].min_depth )
     assert_equal( 6, gram['start'][1].min_depth )
    
     assert_equal( 3, gram['potential'].min_depth )
     assert_equal( 2, gram['potential'].size )
     assert_equal( 2, gram['potential'][0].min_depth )
     assert_equal( 2, gram['potential'][1].min_depth )

     assert_equal( 2, gram['term1'].min_depth )
     assert_equal( 1, gram['term1'].size )
     assert_equal( 1, gram['term1'][0].min_depth )

     assert_equal( 2, gram['term2'].min_depth )
     assert_equal( 2, gram['term2'].size )
     assert_equal( 1, gram['term2'][0].min_depth )
     assert_equal( 1, gram['term2'][1].min_depth )

     assert_equal( 6, gram['loop1'].min_depth )
     assert_equal( 1, gram['loop1'].size )
     assert_equal( 5, gram['loop1'][0].min_depth )

     assert_equal( 5, gram['loop2'].min_depth )
     assert_equal( 2, gram['loop2'].size )
     assert_equal( 4, gram['loop2'][0].min_depth )
     assert_equal( 6, gram['loop2'][1].min_depth )

     assert_equal( 4, gram['loop3'].min_depth )
     assert_equal( 2, gram['loop3'].size )
     assert_equal( 3, gram['loop3'][0].min_depth )
     assert_equal( 6, gram['loop3'][1].min_depth )
  end

  def test_analyze_min_depth_3
    grammar = Mapper::Grammar.new( {
      'node1' => Mapper::Rule.new( [
                   Mapper::RuleAlt.new( [ Mapper::Token.new( :symbol, 'node2' ) ] ),
                   Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'terminal' ) ] )                   
              ] ),
      'node2' => Mapper::Rule.new( [
                   Mapper::RuleAlt.new( [ Mapper::Token.new( :symbol, 'node3' ), Mapper::Token.new( :symbol, 'node3' ) ] )
              ] ),
      'node3' => Mapper::Rule.new( [
                   Mapper::RuleAlt.new( [ Mapper::Token.new( :symbol, 'node4' ), Mapper::Token.new( :symbol, 'node4' ) ] )
              ] ),              
      'node4' => Mapper::Rule.new( [
                   Mapper::RuleAlt.new( [ Mapper::Token.new( :symbol, 'node2' ) ] ),
                   Mapper::RuleAlt.new( [ Mapper::Token.new( :symbol, 'node1' ) ] )                   
              ] ),
    }, 'node1' )

    gram = Validator.analyze_min_depth grammar   

    assert_equal( 2, gram['node1'].min_depth )
    assert_equal( 2, gram['node1'].size )
    assert_equal( 5, gram['node1'][0].min_depth )
    assert_equal( 1, gram['node1'][1].min_depth )

    assert_equal( 5, gram['node2'].min_depth )
    assert_equal( 1, gram['node2'].size )
    assert_equal( 4, gram['node2'][0].min_depth )
    
    assert_equal( 4, gram['node3'].min_depth )
    assert_equal( 1, gram['node3'].size )
    assert_equal( 3, gram['node3'][0].min_depth )
  
    assert_equal( 3, gram['node4'].min_depth )
    assert_equal( 2, gram['node4'].size )
    assert_equal( 5, gram['node4'][0].min_depth )
    assert_equal( 2, gram['node4'][1].min_depth )   
  end

  def test_analyze_min_depth_over_undefined
    exception = assert_raise( RuntimeError ) { Validator.analyze_min_depth @grammar2 }
    assert_equal( "Validator: cannot analyze_min_depth of undefined symbols", exception.message )
  end

  def test_analyze_all
   
    grammar = Mapper::Grammar.new( { 
      'expr' => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'x' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'y' ) ] ),
                  Mapper::RuleAlt.new( [ 
                    Mapper::Token.new( :literal, '(' ), 
                    Mapper::Token.new( :symbol, 'expr' ),
                    Mapper::Token.new( :literal, ' ' ),                   
                    Mapper::Token.new( :symbol, 'aop' ),                  
                    Mapper::Token.new( :symbol, 'expr' ),                   
                    Mapper::Token.new( :literal, ')' ) 
                  ] )
                ] ),

       'aop'  => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '+' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '*' ) ] )
                ] )
    }, 'expr' )

    assert_equal( nil, grammar['expr'].recursivity )   
    assert_equal( nil, grammar['aop'].sn_altering )   
    assert_equal( nil, grammar['expr'].last.arity )   
    assert_equal( nil, grammar['expr'].min_depth )   
  
    g2 = Validator.analyze_all grammar
    assert_equal( grammar, g2 )

    assert_equal( :cyclic, grammar['expr'].recursivity )   
    assert_equal( :nodal, grammar['aop'].sn_altering )      
    assert_equal( 3, grammar['expr'].last.arity )      
    assert_equal( 2, grammar['expr'].min_depth )  

  end
 
end

