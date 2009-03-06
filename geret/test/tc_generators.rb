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
                    Mapper::Token.new( :symbol, 'op', 4 ),                  
                    Mapper::Token.new( :symbol, 'expr', 12 ),                   
                    Mapper::Token.new( :literal, ')' ) 
                  ] )
                ] ),

       'op'  => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '+' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '*' ) ] )
                ] )
    }, 'expr' )

  end

  def test_depth_first_generate
    m = Mapper::DepthFirst.new @grammar
    r = MockRand.new [{1=>0},0,  {1=>0},0,  {2=>0},0,  {2=>0},0,  {2=>1},0,  {2=>1},0,  {1=>0},0,  {2=>1},0, {2=>0},0, {2=>0},0 ]
    m.random = r
    gen = [2, 2, 0, 0, 1, 1, 2, 1, 0, 0] 
    assert_equal( gen, m.generate_full( 2 ) )
    assert_equal( '((x+y)*(y+x))', m.phenotype(gen) )
    assert_equal( 3, m.max_codon_base ) 
  end

  def test_depth_first_unmod
    m = Mapper::DepthFirst.new @grammar   
    r = MockRand.new [{1=>0},{3=>2},  {1=>0},{3=>0},  {2=>0},{3=>1},  {2=>0},{2=>0},  {2=>1},{3=>0},  {2=>1},{2=>1},  {1=>0},{3=>0},  {2=>1},{3=>0}, {2=>0},{2=>1}, {2=>0},{3=>2} ]
    m.random = r
    gen = [2+2*3, 2+0*3, 0+1*3, 0+0*2, 1+0*3, 1+1*2, 2+0*3, 1+1*3, 0+0*2, 0+2*3] 
    m.max_codon_base = 10
    assert_equal( 10, m.max_codon_base ) 
    assert_equal( '((x+y)*(y+x))', m.phenotype(gen) )
  end

  def XXXXXXXXXtest_breadth_first_generate
    m = Mapper::BreadthFirst.new @grammar
    r = Random.new :deterministic

    r.set_predef [0,0,  0,0,  1,0,  0,0,  0,0, 
                  0,0,  1,0,  0,0,  0,0,  1,0,  0,0,  0,0,  1,0]
    m.random = r
    gen = [2,2,1,2,2,   0,1,0,0,1,0,0,1] 
    assert_equal( gen, m.generate_full( 2 ) )
    assert_equal( '(((x+y)+y)*(x+y))', m.phenotype(gen) )
    assert_equal( 3, m.max_codon_base ) 
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

    r = MockRand.new [2,0,  0,0,  0,0,  0,0,  0,0]
    m.random = r
 
    assert_equal( [2], m.generate_full( 300 ) )
  end

  def XXXXXXXtest_depth_locus_generate
    m = Mapper::DepthLocus.new @grammar
    r = Random.new :deterministic

    r.set_predef [0,0,0,  1,0,0,  0,0,0,
                  0,1,0,  1,0,0,  0,0,0,  0,1,0,  0,0,0,  0,1,0,  0,1,0]
    m.random = r
    gen = [0,2,  2,2,  0,2,  
           1,1,  1,0,  0,0,  0,1,  0,0,  1,1,  0,1] 
    assert_equal( gen, m.generate_full( 2 ) )
    assert_equal( '(y*((x*x)*x))', m.phenotype(gen) )
    assert_equal( 3, m.max_codon_base ) 
  end 

end

