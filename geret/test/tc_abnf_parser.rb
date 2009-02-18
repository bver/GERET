#!/usr/bin/ruby

require 'test/unit'
require 'lib/abnf_parser'
require 'lib/abnf_tokenizer' #todo: remove
require 'lib/abnf_renderer' #todo: remove

include Mapper
include Abnf

class TC_AbnfParser < Test::Unit::TestCase

  def setup
    @tokeniser = Tokenizer.new #todo: remove 
    @parser = Parser.new

    @grammar1 = Grammar.new( { 
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

  end

  def test_basic #todo: remove dependencies
    example = <<ABNF_TEXT
       expr = "x" / "y" / "(" expr op expr ")"

       op = "+" / "*"
ABNF_TEXT

    assert_equal( @grammar1, @parser.parse( @tokeniser.tokenize( example ) ) )

  end

  def test_alternatives #todo: remove dependencies 
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

  def test_rules_on_more_rows #todo: remove dependencies 
    example = <<ABNF_TEXT
       expr = "x" / 
              "y" / 
              "(" expr op expr ")"
       op = "+" / 
            "*"
ABNF_TEXT

    assert_equal( @grammar1, @parser.parse( @tokeniser.tokenize( example ) ) )
  end
    
  def test_incremental #todo: remove dependencies 
    example = <<ABNF_TEXT
       expr ="x" 
       op= "+"
       expr=/ "y" 
       op =/"*"
       expr =/"(" expr op expr ")"
ABNF_TEXT

    assert_equal( @grammar1, @parser.parse( @tokeniser.tokenize( example ) ) )
  end

  def test_mismatching_brackets
    # ( [) ] and so on
  end

  def test_optionals
    stream = [
      Token.new( :symbol, 'foo' ),
      Token.new( :equals ),
      Token.new( :opt_begin ),
      Token.new( :literal, 'abc' ),
      Token.new( :space ),
      Token.new( :literal, 'xyz' ),
      Token.new( :opt_end ),
      Token.new( :literal, 'end' ),     
      Token.new( :eof )      
    ]

    grammar = Grammar.new( { 
      'foo' => Rule.new( [ 
                 RuleAlt.new( [ 
                    Token.new( :symbol, 'foo_opt1' ),
                    Token.new( :literal, 'end' ) 
                 ] )
               ] ),

      'foo_opt1' => Rule.new( [ 
                      RuleAlt.new( [ 
                        Token.new( :literal, '' ) 
                      ] ),                            
                      RuleAlt.new( [ 
                        Token.new( :literal, 'abc' ),
                        Token.new( :literal, 'xyz' ) 
                      ] )
                    ] )
    }, 'foo' )
   
    assert_equal( grammar, @parser.parse( stream ) )

  end

  def test_undefined_symbol
    # todo
  end

  def test_already_defined_symbol
    # todo
  end
end

