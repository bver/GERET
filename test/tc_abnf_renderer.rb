#!/usr/bin/ruby

require 'test/unit'
require 'lib/abnf_renderer'

include Mapper

class TC_AbnfRenderer < Test::Unit::TestCase

  def test_basic
     grammar = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ Token.new( :literal, 'x' ) ] ),
                  RuleAlt.new( [ Token.new( :literal, 'y' ) ] ),
                  RuleAlt.new( [ 
                    Token.new( :literal, '(' ), 
                    Token.new( :symbol, 'expr' ),
                    Token.new( :symbol, 'op' ),                  
                    Token.new( :symbol, 'expr' ),                   
                    Token.new( :literal, ')' ) 
                  ] )
                ] ),

       'op'  => Rule.new( [ 
                  RuleAlt.new( [ Token.new( :literal, '+' ) ] ),
                  RuleAlt.new( [ Token.new( :literal, '*' ) ] )
                ] )
    }, 'expr' )

    example = <<ABNF_TEXT
;start symbol is <expr>
expr = "x"
expr =/ "y"
expr =/ "(" expr op expr ")"

op = "+"
op =/ "*"

ABNF_TEXT

    assert_equal( example, Abnf::Renderer.canonical(grammar) )

  end

end

