#!/usr/bin/ruby

require 'test/unit'
require 'lib/abnf_parser'
require 'lib/abnf_tokenizer'

include Mapper

class TC_AbnfParser < Test::Unit::TestCase

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
       expr = "x" / "y" / "(" expr op expr ")"
       op = "+" / "*"
ABNF_TEXT

    tokeniser = Abnf::Tokenizer.new 
    parser = Abnf::Parser.new
    assert_equal( grammar, parser.parse( tokeniser.tokenize( example ) ) )

  end

end

