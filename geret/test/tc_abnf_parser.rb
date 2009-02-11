#!/usr/bin/ruby

require 'test/unit'
require 'lib/abnf_parser'
require 'lib/abnf_tokenizer'

class TC_AbnfParser < Test::Unit::TestCase

  def test_basic
     grammar = Mapper::Grammar.new( { 
      'expr' => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'x' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'y' ) ] ),
                  Mapper::RuleAlt.new( [ 
                    Mapper::Token.new( :literal, '(' ), 
                    Mapper::Token.new( :symbol, 'expr' ),
                    Mapper::Token.new( :symbol, 'op' ),                  
                    Mapper::Token.new( :symbol, 'expr' ),                   
                    Mapper::Token.new( :literal, ')' ) 
                  ] )
                ] ),

       'op'  => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '+' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '*' ) ] )
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

