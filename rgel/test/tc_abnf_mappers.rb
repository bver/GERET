#!/usr/bin/ruby

require 'test/unit'
require 'lib/abnf_mappers'

class TC_AbnfMappers < Test::Unit::TestCase

  def setup
    @grammar = Abnf::Grammar.new( { 
      'expr' => Abnf::Rule.new( [ 
                  Abnf::RuleAlt.new( [ Abnf::Token.new( :literal, 'x' ) ] ),
                  Abnf::RuleAlt.new( [ Abnf::Token.new( :literal, 'y' ) ] ),
                  Abnf::RuleAlt.new( [ 
                    Abnf::Token.new( :literal, '(' ), 
                    Abnf::Token.new( :literal, 'expr' ),
                    Abnf::Token.new( :literal, ' ' ),                   
                    Abnf::Token.new( :literal, 'op' ),                  
                    Abnf::Token.new( :literal, 'expr' ),                   
                    Abnf::Token.new( :literal, ')' ) 
                  ] )
                ] ),

       'op'  => Abnf::Rule.new( [ 
                  Abnf::RuleAlt.new( [ Abnf::Token.new( :literal, '+' ) ] ),
                  Abnf::RuleAlt.new( [ Abnf::Token.new( :literal, '*' ) ] )
                ] )
    }, 'expr' )

  end

  def test_trivia
    assert_equal( 'expr', @grammar.start_symbol )
    @grammar.start_symbol = 'op'
    assert_equal( 'op', @grammar.start_symbol )
  end

  def test_depth_first
    m = Mapper::DepthFirst.new @grammar

    assert_equal( @grammar, m.grammar )

    assert_equal( '((x +y) *x)', m.phenotype( [2, 2, 0, 0, 1, 1, 0] ) )      
    assert_equal( '((x +y) *x)', m.phenotype( [5, 8, 3, 4, 1, 3, 6, 5, 3] ) )

    assert_equal( '(y *(x +y))', m.phenotype( [2, 1, 1, 2, 0, 0, 1] ) )   
    assert_equal( '(y *(x +y))', m.phenotype( [2, 4, 3, 5, 0, 6, 1, 3, 5] ) )      
  end

  def test_breadth_first
    m = Mapper::BreadthFirst.new @grammar

    assert_equal( @grammar, m.grammar )

    assert_equal( '((x +y) *x)', m.phenotype( [2, 2, 1, 0, 0, 0, 1] ) )      
    assert_equal( '((x +y) *x)', m.phenotype( [2, 5, 1, 3, 6, 2, 4, 5, 3] ) )

    assert_equal( '(y *(x +y))', m.phenotype( [2, 1, 1, 2, 0, 0, 1] ) )   
    assert_equal( '(y *(x +y))', m.phenotype( [2, 4, 3, 5, 0, 6, 1, 3, 5] ) )      
  end
 

end
