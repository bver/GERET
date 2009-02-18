#!/usr/bin/ruby

require 'test/unit'
require 'lib/abnf_parser'

include Mapper
include Abnf

class TC_AbnfParser < Test::Unit::TestCase

  def setup
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

  def test_basic 

     stream = [

      #expr = "x" / "y" / "(" expr op expr ")"
      Token.new( :symbol, 'expr' ),
      Token.new( :space ),          
      Token.new( :equals ),
      Token.new( :space ),     
      Token.new( :literal, 'x' ),
      Token.new( :space ),
      Token.new( :slash ),          
      Token.new( :space ),          
      Token.new( :literal, 'y' ),
      Token.new( :space ),          
      Token.new( :slash ),          
      Token.new( :space ),          
      Token.new( :literal, '(' ),
      Token.new( :space ),      
      Token.new( :symbol, 'expr' ),
      Token.new( :space ),      
      Token.new( :symbol, 'op' ),
      Token.new( :space ),      
      Token.new( :symbol, 'expr' ),
      Token.new( :space ),      
      Token.new( :space ),          
      Token.new( :literal, ')' ),
      Token.new( :newline ),          

      Token.new( :newline ),          
 
      #op = "+" / "*"
      Token.new( :symbol, 'op' ),
      Token.new( :space ),          
      Token.new( :equals ),
      Token.new( :space ),     
      Token.new( :literal, '+' ),
      Token.new( :space ),
      Token.new( :slash ),          
      Token.new( :space ),          
      Token.new( :literal, '*' ),
      Token.new( :space ),          
    
      Token.new( :eof )      
    ]

    assert_equal( @grammar1, @parser.parse( stream ) )

  end

  def test_alternatives 
     
    #symb="begin"("alt1"/"alt2"/"alt3a" "alt3b")"end"
    stream = [
      Token.new( :symbol, 'symb' ),
      Token.new( :equals ),
      Token.new( :literal, 'begin' ),
      Token.new( :seq_begin ),
      Token.new( :literal, 'alt1' ),
      Token.new( :slash ),
      Token.new( :literal, 'alt2' ),
      Token.new( :slash ),
      Token.new( :literal, 'alt3a' ),
      Token.new( :space ),          
      Token.new( :literal, 'alt3b' ),
      Token.new( :seq_end ),
      Token.new( :literal, 'end' ),
      Token.new( :eof )
    ]
   
    #canonical:
    #symb = "begin" symb_grp1 "end"
    #symb_grp1 = "alt1"
    #symb_grp1 =/ "alt2"
    #symb_grp1 =/ "alt3a" "alt3b"

    grammar = Grammar.new( { 
      'symb' => Rule.new( [ 
                  RuleAlt.new( [ 
                    Token.new( :literal, 'begin' ), 
                    Token.new( :symbol, 'symb_grp1' ),
                    Token.new( :literal, 'end' ) 
                 ] )
               ] ),
      'symb_grp1' => Rule.new( [ 
                       RuleAlt.new( [ 
                         Token.new( :literal, 'alt1' ) 
                       ] ),                            
                       RuleAlt.new( [ 
                         Token.new( :literal, 'alt2' ) 
                       ] ),                            
                       RuleAlt.new( [ 
                         Token.new( :literal, 'alt3a' ),
                         Token.new( :literal, 'alt3b' ) 
                       ] )
                     ] )
    }, 'symb' )
                 
    assert_equal( grammar, @parser.parse( stream ) )
     
  end

  def test_rules_on_more_rows 

    stream = [
      #expr = "x" /
      Token.new( :symbol, 'expr' ),
      Token.new( :space ),          
      Token.new( :equals ),
      Token.new( :space ),     
      Token.new( :literal, 'x' ),
      Token.new( :space ),
      Token.new( :slash ),          
      Token.new( :space ),          
      Token.new( :newline ),          

      #  "y" /   
      Token.new( :space ),          
      Token.new( :literal, 'y' ),
      Token.new( :space ),          
      Token.new( :slash ),          
      Token.new( :newline ),          

      #  "(" expr op expr ")"
      Token.new( :space ),          
      Token.new( :literal, '(' ),
      Token.new( :space ),      
      Token.new( :symbol, 'expr' ),
      Token.new( :space ),      
      Token.new( :symbol, 'op' ),
      Token.new( :space ),      
      Token.new( :symbol, 'expr' ),
      Token.new( :space ),      
      Token.new( :space ),          
      Token.new( :literal, ')' ),
      Token.new( :newline ),          
      
      #op = "+" /
      Token.new( :symbol, 'op' ),
      Token.new( :space ),          
      Token.new( :equals ),
      Token.new( :space ),     
      Token.new( :literal, '+' ),
      Token.new( :space ),
      Token.new( :slash ),          
      Token.new( :newline ), 

      #  "*" 
      Token.new( :space ),          
      Token.new( :literal, '*' ),
      Token.new( :space ),          
      Token.new( :newline ),          
    
      Token.new( :eof )      
    ]

    assert_equal( @grammar1, @parser.parse( stream ) )
  end
    
  def test_incremental

     stream = [
      #expr ="x"
      Token.new( :symbol, 'expr' ),
      Token.new( :space ),          
      Token.new( :equals ),
      Token.new( :literal, 'x' ),
      Token.new( :newline ),          

      #op= "+" 
      Token.new( :symbol, 'op' ),
      Token.new( :equals ),
      Token.new( :space ),     
      Token.new( :literal, '+' ),
      Token.new( :space ),
      Token.new( :newline ), 

      #expr=/ "y"
      Token.new( :symbol, 'expr' ),
      Token.new( :eq_slash ),
      Token.new( :space ),          
      Token.new( :literal, 'y' ),
      Token.new( :newline ),          

      Token.new( :newline ),          

      #op =/"*"
      Token.new( :symbol, 'op' ),
      Token.new( :space ),   
      Token.new( :eq_slash ),
      Token.new( :literal, '*' ),
      Token.new( :newline ),          

      #expr=/"(" expr op expr ")"
      Token.new( :symbol, 'expr' ),
      Token.new( :eq_slash ),
      Token.new( :literal, '(' ),
      Token.new( :space ),      
      Token.new( :symbol, 'expr' ),
      Token.new( :space ),      
      Token.new( :symbol, 'op' ),
      Token.new( :space ),      
      Token.new( :symbol, 'expr' ),
      Token.new( :space ),      
      Token.new( :space ),          
      Token.new( :literal, ')' ),
      Token.new( :space ),          
      Token.new( :newline ),          
   
      Token.new( :eof )      
    ]

    assert_equal( @grammar1, @parser.parse( stream ) )
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

