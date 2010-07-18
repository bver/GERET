#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/mapper'

class TC_Generators < Test::Unit::TestCase

  def setup
    @grammar = Mapper::Grammar.new( { 
      'expr' => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'x' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'y' ) ] ),
                  Mapper::RuleAlt.new( [ 
                    Mapper::Token.new( :literal, '(' ), 
                    Mapper::Token.new( :symbol, 'expr', 42 ),
                    Mapper::Token.new( :symbol, 'aop', 4 ),                  
                    Mapper::Token.new( :symbol, 'expr', 12 ),                   
                    Mapper::Token.new( :literal, ')' ) 
                  ] )
                ] ),

       'aop'  => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '+' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '*' ) ] )
                ] )
    }, 'expr' )

  end

  def test_require_depth_too_big
    grammar = Mapper::Grammar.new( { 
      'expr' => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'x' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'y' ) ] ),
                  Mapper::RuleAlt.new( [ 
                    Mapper::Token.new( :literal, '(' ), 
                    Mapper::Token.new( :symbol, 'op', 4 ),                  
                    Mapper::Token.new( :literal, ')' ) 
                  ] )
                ] ),

       'op'  => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '+' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '*' ) ] )
                ] )
    }, 'expr' )

    m = Mapper::BreadthFirst.new grammar
    assert_equal( :terminating, m.grammar[m.grammar.start_symbol].recursivity )

    r = MockRand.new [2,0,  0,0]
    m.random = r
 
    assert_equal( [2, 0], m.generate_full( 300 ) )
  end

  def test_infinite_grammar
    grammar = Mapper::Grammar.new( { 
      'expr' => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'x' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'y' ) ] ),
                  Mapper::RuleAlt.new( [ 
                    Mapper::Token.new( :literal, '(' ), 
                    Mapper::Token.new( :symbol, 'op', 4 ),                  
                    Mapper::Token.new( :literal, ')' ) 
                  ] )
                ] ),

       'op'  => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :symbol, 'op' ) ] ),
                ] )
    }, 'expr' )

    m = Mapper::BreadthFirst.new grammar
    assert_equal( :infinite, m.grammar['op'].recursivity )
    assert_equal( :cyclic, m.grammar['expr'].recursivity )

    r = MockRand.new [ {2=>1}, {85=>0} ]
    m.random = r

    assert_equal( [1], m.generate_full( 300 ) )
  end

  def test_depth_first_full
    m = Mapper::DepthFirst.new @grammar
    r = MockRand.new [{1=>0},0,  {1=>0},0,  {2=>0},0,  {2=>0},0,  {2=>1},0,  {2=>1},0,  {1=>0},0,  {2=>1},0, {2=>0},0, {2=>0},0 ]
    m.random = r
    gen = [2, 2, 0, 0, 1, 1, 2, 1, 0, 0] 
    assert_equal( gen, m.generate_full( 3 ) ) # 2
    assert_equal( '((x+y)*(y+x))', m.phenotype(gen) )
  end

  def test_depth_first_unmod
    m = Mapper::DepthFirst.new @grammar   
    r = MockRand.new [{1=>0},{3=>2},  {1=>0},{3=>0},  {2=>0},{3=>1},  {2=>0},{2=>0},  {2=>1},{3=>0},  {2=>1},{2=>1},  {1=>0},{3=>0},  {2=>1},{3=>0}, {2=>0},{2=>1}, {2=>0},{3=>2} ]
    m.random = r
    gen = [2+2*3, 2+0*3, 0+1*3, 0+0*2, 1+0*3, 1+1*2, 2+0*3, 1+1*3, 0+0*2, 0+2*3] 
    assert_equal( '((x+y)*(y+x))', m.phenotype(gen) )
  end

  def test_breadth_first_full
    m = Mapper::BreadthFirst.new @grammar
    r = MockRand.new [{1=>0},0, {1=>0},0, {2=>1},0, {1=>0},0, {2=>0},0, {2=>0},0, {2=>1},0, {2=>1},0, {2=>0},0, {2=>0},0]
    m.random = r
    gen = [2, 2, 1, 2, 0, 0, 1, 1, 0, 0] 
    assert_equal( gen, m.generate_full( 3 ) ) # 2
    assert_equal( '((x+y)*(y+x))', m.phenotype(gen) )
  end
 
  def test_depth_locus_full
    m = Mapper::DepthLocus.new @grammar
    r = MockRand.new [{1=>0},{1=>0},0, {3=>1},{2=>1},0, {2=>1},{1=>0},0, {3=>0},{2=>1},0, {2=>1},{2=>1},0, 
                      {1=>0},{2=>0},0, {1=>0},{1=>0},0, {3=>2},{2=>0},0, {2=>1},{2=>0},0, {1=>0},{2=>0},0]     
    m.random = r
    gen = [0,2,  1,1,  1,2,  0,1,  1,1,  0,0,  0,2,  2,0,  1,0,  0,0] 
    assert_equal( gen, m.generate_full( 3 ) ) # 2
    assert_equal( '((x+x)*(y+y))', m.phenotype(gen) )
  end 

  def test_depth_first_grow
    m = Mapper::DepthFirst.new @grammar   
    r = MockRand.new [{3=>2},0, {3=>1},0, {2=>0},0, {3=>2},0, {3=>2},0, {2=>0},0, {2=>0},0, {2=>0},0, {2=>1},0, {3=>1},0]
    m.random = r   
    gen = [2,1,0,2,2,0,0,0,1,1]
    assert_equal( gen, m.generate_grow( 4 ) ) # 3
    assert_equal( '(y+((x+x)*y))', m.phenotype(gen) )
  end

  def test_depth_locus_grow
    m = Mapper::DepthLocus.new @grammar   
    r = MockRand.new [{1=>0},{3=>2},0, {3=>2},{3=>1},0, {2=>1},{2=>1},0, {1=>0},{3=>0},0]
    m.random = r   
    gen = [0,2,  2,1,  1,1,  0,0]
    assert_equal( gen, m.generate_grow( 5 ) )
    assert_equal( '(x*y)', m.phenotype(gen) )
  end

  def test_generate_trivial
    m = Mapper::DepthFirst.new @grammar   
    r = MockRand.new [{2=>0},0]
    m.random = r   
    gen = [0]
    assert_equal( gen, m.generate( [:terminating], 3 ) )
    assert_equal( 'x', m.phenotype(gen) )
  end

  def test_breath_bucket_full
    m = Mapper::BreadthBucket.new @grammar 
    r = MockRand.new [{1=>0}, {85=>0}, {1=>0}, {85=>0}, {2=>1}, {128=>0}, {1=>0}, {85=>0}, {2=>0}, {85=>0}, {2=>0}, {128=>0}, {2=>1}, {85=>0}, {2=>1}, {85=>0}, {2=>0}, {128=>0}, {2=>0}, {85=>0}]   
    m.random = r
    gen = [2*2, 2*2, 1*1, 2*2, 0*2, 0*1, 1*2, 1*2, 0*1, 0*2] 
    assert_equal( gen, m.generate_full( 3 ) ) # 2
    assert_equal( '((x+y)*(y+x))', m.phenotype(gen) )
  end

  def test_depth_bucket_full
    m = Mapper::DepthBucket.new @grammar   
    r = MockRand.new [{1=>0}, {85=>0}, {1=>0}, {85=>0}, {2=>0}, {85=>0}, {2=>0}, {128=>0}, {2=>1}, {85=>0}, {2=>1}, {128=>0}, {1=>0}, {85=>0}, {2=>1}, {85=>0}, {2=>0}, {128=>0}, {2=>0}, {85=>0}]
 

    m.random = r  
    gen = [2*2, 2*2, 0*2, 0*1, 1*2, 1*1, 2*2, 1*2, 0*1, 0*2]    
    assert_equal( gen, m.generate_full( 3 ) ) # 2
    assert_equal( '((x+y)*(y+x))', m.phenotype(gen) )
  end

  def test_all_locus_grow
    m = Mapper::AllLocus.new @grammar
    r = MockRand.new [{1=>0},{1=>0},0, {3=>2},{1=>0},0, {5=>3},{2=>0},0, {4=>1},{2=>1},0, {3=>1},{2=>0},0, 
                      {2=>0},{1=>0},0, {4=>0},{2=>1},0, {3=>0},{2=>0},0, {2=>1},{2=>1},0, {1=>0},{2=>0},0, ]
    m.random = r
    gen = [0,2,  2,2,  3,0,  1,1,  1,0,  0,2,  0,1,  0,0,  1,1,  0,0] 
    assert_equal( gen, m.generate_full( 3 ) ) # 2
    assert_equal( '((y+x)*(x+y))', m.phenotype(gen) )
  end
 
  def test_locus_generator_eating
    grammar = Mapper::Grammar.new( { 
      'expr' => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'x' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'y' ) ] ),
                  Mapper::RuleAlt.new( [ 
                    Mapper::Token.new( :literal, '(' ), 
                    Mapper::Token.new( :symbol, 'expr', 42 ),
                    Mapper::Token.new( :symbol, 'op', 4 ),                  
                    Mapper::Token.new( :symbol, 'expr', 12 ),                   
                    Mapper::Token.new( :literal, ')' ) 
                  ] )
                ] ),

       'op'  => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '+' ) ] ), #trivial rule
                ] )
    }, 'expr' )
 
    m = Mapper::BreadthFirst.new grammar
    assert_equal( true, m.consume_trivial_codons )   
    m.consume_trivial_codons = false
    assert_equal( false, m.consume_trivial_codons )                             

    r = MockRand.new [{1=>0},0, {1=>0},0,           {1=>0},0, {2=>0},0, 
                                {2=>1},0, {2=>1},0,           {2=>0},0]
    m.random = r
         #[2, 2, 0, 2, 0, 0, 1, 1, 0, 0]   
    gen = [2, 2,    2, 0,    1, 1,    0] 
    assert_equal( '((x+y)+(y+x))', m.phenotype(gen) )
    assert_equal( gen, m.generate_full( 3 ) )  # 2 
    assert_equal( 7, m.used_length )   

    m = Mapper::DepthLocus.new grammar
    assert_equal( true, m.consume_trivial_codons )   
    m.consume_trivial_codons = false
    assert_equal( false, m.consume_trivial_codons )                             

    r = MockRand.new [       {1=>0},0,  {3=>2},{1=>0},0,  {3=>1},           {2=>0},{2=>1},0,      {2=>0},0, 
                      {2=>0},{1=>0},0,  {3=>1},           {2=>0},{2=>0},0,         {2=>1},0,              ]     
         #[0,2,  2,2,  1,0,  0,1,  0,0,  0,2,  1,0,  0,0,  0,1,  0,1]        
    m.random = r

    gen = [  2,  2,2,  1,    0,1,    0,  0,2,  1,    0,0,    1      ] 
    assert_equal( gen,  m.generate_full( 3 ) ) # 2
    assert_equal( '((x+y)+(y+x))',  m.phenotype( gen ) )      
    assert_equal( 13, m.used_length )   
  end
  
  def test_deep_cyclic_grammar
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

    m = Mapper::DepthFirst.new grammar 
    assert_equal( 4, m.grammar.symbols.size )
    cyclic = m.grammar.symbols.find_all {|s| m.grammar[s].recursivity == :cyclic }
    assert_equal( 4, cyclic.size )   

    r = MockRand.new [ {1=>0}, {128=>0} ]
    m.random = r   
    gen = [1]
    
    assert_equal( gen, m.generate( [:cycling], 3 ) )
    assert_equal( 'terminal', m.phenotype(gen) )
  end

  def test_insufficient_min_depth
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
   
     m = Mapper::DepthFirst.new grammar 

     r = MockRand.new []
     m.random = r   
   
     assert_equal( 4, m.grammar['start'].min_depth )
     assert_equal( 2, m.grammar['start'].size )
     assert_equal( 3, m.grammar['start'][0].min_depth )
     assert_equal( 6, m.grammar['start'][1].min_depth )
 
     exception = assert_raise( RuntimeError ) { m.generate_full( 2 ) }
     assert_equal( "Generator: required_depth<min_depth, please increase sensible_depth", exception.message )
  end

end

