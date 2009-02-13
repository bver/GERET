#!/usr/bin/ruby

require 'test/unit'
require 'lib/abnf_parser'
require 'lib/abnf_tokenizer'
require 'lib/abnf_renderer'

include Mapper
include Abnf

class TC_AbnfParser < Test::Unit::TestCase

  def setup
    @tokeniser = Tokenizer.new 
    @parser = Parser.new
  end

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

    assert_equal( grammar, @parser.parse( @tokeniser.tokenize( example ) ) )

  end

  def test_alternatives
     example = %q#symb = "begin" ( "alt1" / "alt2" / "alt3a" "alt3b" ) "end"# + "\n"

     canonical = <<ABNF_TEXT
symb = "begin" symb_grp1 "end"

symb_grp1 = "alt1"
symb_grp1 =/ "alt2"
symb_grp1 =/ "alt3a" "alt3b"

ABNF_TEXT

     grammar = @parser.parse( @tokeniser.tokenize( example ) )
     assert_equal( canonical, Renderer.canonical( grammar ) ) 
     
  end

  def test_rule_on_more_rows
    #TODO one rule across :newline token
  end
    
  def test_incremental
    #TODO =/ parsing
  end

  def test_mismatching_brackets
    # ( [) ] and so on
  end

end

