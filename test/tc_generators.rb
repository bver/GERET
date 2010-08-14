#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/mapper'
require 'lib/validator'
require 'lib/codon_mod'
require 'lib/codon_bucket'

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
   
    Mapper::Validator.analyze_all @grammar

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

    Mapper::Validator.analyze_all grammar 

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
    
    Mapper::Validator.analyze_all grammar

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
    r = MockRand.new [{1=>0},0,{1=>0},0, {3=>1},0,{2=>1},0, {2=>1},0,{1=>0},0, {3=>0},0,{2=>1},0, {2=>1},0,{2=>1},0, 
                      {1=>0},0,{2=>0},0, {1=>0},0,{1=>0},0, {3=>2},0,{2=>0},0, {2=>1},0,{2=>0},0, {1=>0},0,{2=>0},0]     
    m.random = r
    gen = [0,2,  1,1,  1,2,  0,1,  1,1,  0,0,  0,2,  2,0,  1,0,  0,0] 
    assert_equal( gen, m.generate_full( 3 ) ) # 2
    assert_equal( '((x+x)*(y+y))', m.phenotype(gen) )
  end 

  def test_depth_locus_fading_bugfix
    m = Mapper::DepthLocus.new @grammar
    m.wraps_to_fading = 2
    r = MockRand.new [{1=>0},0,{1=>0},0, {3=>1},0,{2=>1},0, {2=>1},0,{1=>0},0, {3=>0},0,{2=>1},0, {2=>1},0,{2=>1},0, 
                      {1=>0},0,{2=>0},0, {1=>0},0,{1=>0},0, {3=>2},0,{2=>0},0, {2=>1},0,{2=>0},0, {1=>0},0,{2=>0},0]     
    m.random = r
    gen = [0,2,  1,1,  1,2,  0,1,  1,1,  0,0,  0,2,  2,0,  1,0,  0,0] 
    assert_equal( gen, m.generate_full( 3 ) ) # 2
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
    r = MockRand.new [{1=>0},0,{3=>2},0, {3=>2},0,{3=>1},0, {2=>1},0,{2=>1},0, {1=>0},0,{3=>0},0]
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
    m = Mapper::BreadthFirst.new @grammar 
    m.codon = Mapper::CodonBucket.new
    m.codon.grammar = @grammar
   
    r = MockRand.new [{1=>0}, {85=>0}, {1=>0}, {85=>0}, {2=>1}, {128=>0}, {1=>0}, {85=>0}, {2=>0}, {85=>0}, {2=>0}, {128=>0}, {2=>1}, {85=>0}, {2=>1}, {85=>0}, {2=>0}, {128=>0}, {2=>0}, {85=>0}]   
    m.random = r
    gen = [2*2, 2*2, 1*1, 2*2, 0*2, 0*1, 1*2, 1*2, 0*1, 0*2] 
    assert_equal( gen, m.generate_full( 3 ) ) # 2
    assert_equal( '((x+y)*(y+x))', m.phenotype(gen) )
  end

  def test_depth_bucket_full
    m = Mapper::DepthFirst.new @grammar   
    m.codon = Mapper::CodonBucket.new
    m.codon.grammar = @grammar
   
    r = MockRand.new [{1=>0}, {85=>0}, {1=>0}, {85=>0}, {2=>0}, {85=>0}, {2=>0}, {128=>0}, {2=>1}, {85=>0}, {2=>1}, {128=>0}, {1=>0}, {85=>0}, {2=>1}, {85=>0}, {2=>0}, {128=>0}, {2=>0}, {85=>0}]
 

    m.random = r  
    gen = [2*2, 2*2, 0*2, 0*1, 1*2, 1*1, 2*2, 1*2, 0*1, 0*2]    
    assert_equal( gen, m.generate_full( 3 ) ) # 2
    assert_equal( '((x+y)*(y+x))', m.phenotype(gen) )
  end

  def test_all_locus_grow
    m = Mapper::AllLocus.new @grammar
    r = MockRand.new [{1=>0},0,{1=>0},0, {3=>2},0,{1=>0},0, {5=>3},0,{2=>0},0, {4=>1},0,{2=>1},0, {3=>1},0,{2=>0},0, 
                      {2=>0},0,{1=>0},0, {4=>0},0,{2=>1},0, {3=>0},0,{2=>0},0, {2=>1},0,{2=>1},0, {1=>0},0,{2=>0},0 ]
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

    Mapper::Validator.analyze_all grammar 
 
    m = Mapper::BreadthFirst.new grammar
    assert_equal( true, m.consume_trivial_codons )   
    m.consume_trivial_codons = false
    assert_equal( false, m.consume_trivial_codons )                             
    assert_equal( 0, m.generated_count )   

    r = MockRand.new [{1=>0},0, {1=>0},0,           {1=>0},0, {2=>0},0, 
                                {2=>1},0, {2=>1},0,           {2=>0},0]
    m.random = r
         #[2, 2, 0, 2, 0, 0, 1, 1, 0, 0]   
    gen = [2, 2,    2, 0,    1, 1,    0] 
    assert_equal( '((x+y)+(y+x))', m.phenotype(gen) )
    assert_equal( gen, m.generate_full( 3 ) )  # 2 
    assert_equal( 7, m.used_length )   
    assert_equal( 1, m.generated_count )  

    m.random = MockRand.new [{1=>0},0, {1=>0},0, {1=>0},0, {2=>0},0, {2=>1},0, {2=>1},0, {2=>0},0]
    m.generate_full( 3 )
    assert_equal( 2, m.generated_count )  

    m = Mapper::DepthLocus.new grammar
    assert_equal( true, m.consume_trivial_codons )   
    m.consume_trivial_codons = false
    assert_equal( false, m.consume_trivial_codons )                             

    r = MockRand.new [         {1=>0},0,  {3=>2},0,{1=>0},0,  {3=>1},0,           {2=>0},0,{2=>1},0,      {2=>0},0, 
                      {2=>0},0,{1=>0},0,  {3=>1},0,           {2=>0},0,{2=>0},0,           {2=>1},0,                ]     
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

    Mapper::Validator.analyze_all grammar
             
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
    grammar = Mapper::Grammar.new( { 
      'start' => Mapper::Rule.new( [ # min_depth=4
                   Mapper::RuleAlt.new( [ # min_depth=3 
                     Mapper::Token.new( :literal, 'one' ),
                     Mapper::Token.new( :symbol, 'potential' ), 
                     Mapper::Token.new( :literal, 'two' ),                   
                   ] ),
                   Mapper::RuleAlt.new( [ # min_depth=6 
                     Mapper::Token.new( :symbol, 'loop1' ), 
                     Mapper::Token.new( :literal, 'three' ),                   
                   ] ),
                 ] ),
      'potential' => Mapper::Rule.new( [ # min_depth=3 
                   Mapper::RuleAlt.new( [ # min_depth=2 
                     Mapper::Token.new( :literal, 'one' ),
                     Mapper::Token.new( :symbol, 'term1' ), 
                   ] ),
                   Mapper::RuleAlt.new( [ # min_depth=2 
                     Mapper::Token.new( :symbol, 'term2' ), 
                     Mapper::Token.new( :symbol, 'term1' ),                   
                   ] ),
                 ] ),                
      'term1' => Mapper::Rule.new( [  # min_depth=2 
                   Mapper::RuleAlt.new( [ # min_depth=1 
                     Mapper::Token.new( :literal, 'T1' ),
                   ] ),
                 ] ),                
      'term2' => Mapper::Rule.new( [ # min_depth=2 
                   Mapper::RuleAlt.new( [ # min_depth=1 
                     Mapper::Token.new( :literal, 'T2A' ),
                   ] ),
                   Mapper::RuleAlt.new( [ # min_depth=1 
                     Mapper::Token.new( :literal, 'T2B' ),
                   ] ),
                 ] ),                
      'loop1' => Mapper::Rule.new( [ # min_depth=6
                   Mapper::RuleAlt.new( [ # min_depth=5 
                     Mapper::Token.new( :symbol, 'loop3' ), 
                     Mapper::Token.new( :symbol, 'loop2' ),                   
                   ] ),
                 ] ),                
      'loop2' => Mapper::Rule.new( [ # min_depth=5 
                   Mapper::RuleAlt.new( [ # min_depth=4 
                     Mapper::Token.new( :symbol, 'loop3' ), 
                   ] ),
                   Mapper::RuleAlt.new( [ # min_depth=6 
                     Mapper::Token.new( :symbol, 'loop1' ),                   
                   ] ),
                 ] ),                
      'loop3' => Mapper::Rule.new( [ # min_depth=4 
                   Mapper::RuleAlt.new( [ # min_depth=3 
                     Mapper::Token.new( :symbol, 'potential' ), 
                   ] ),
                   Mapper::RuleAlt.new( [ # min_depth=6 
                     Mapper::Token.new( :symbol, 'loop1' ), 
                   ] ),
                 ] ),                
     }, 'start' )

     Mapper::Validator.analyze_all grammar 

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

  def test_codon_interface
    m = Mapper::DepthFirst.new @grammar
    assert_equal( 8, m.codon.bit_size )
    m.codon.bit_size = 5
    assert_equal( 5, m.codon.bit_size )
    m.codon = Mapper::CodonMod.new 7 
    assert_equal( 7, m.codon.bit_size )
  end

end

