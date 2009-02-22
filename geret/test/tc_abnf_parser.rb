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
    stream = [
      #op=["+")
      Token.new( :symbol, 'op' ),
      Token.new( :equals ),
      Token.new( :opt_begin ),
      Token.new( :literal, '+' ),
      Token.new( :seq_end ),
      Token.new( :eof ),
    ]

    exception = assert_raise( RuntimeError ) { @parser.parse( stream ) }
    assert_equal( "Parser: missing 'opt_end' token", exception.message )

    stream = [
      #op=["+"
      Token.new( :symbol, 'op' ),
      Token.new( :equals ),
      Token.new( :opt_begin ),
      Token.new( :literal, '+' ),
      Token.new( :eof ),
    ]

    exception = assert_raise( RuntimeError ) { @parser.parse( stream ) }
    assert_equal( "Parser: missing 'opt_end' token", exception.message )
   
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
 
    assert_equal( [], Parser.check_symbols( @grammar1 ) )

    grammar = Grammar.new( { 
      'foo' => Rule.new( [ 
                 RuleAlt.new( [ 
                    Token.new( :symbol, 'foo_opt1' ),
                    Token.new( :symbol, 'unknown1' ) 
                 ] )
               ] ),

      'foo_opt1' => Rule.new( [ 
                      RuleAlt.new( [ 
                        Token.new( :literal, 'bar' ) 
                      ] ),                            
                      RuleAlt.new( [ 
                        Token.new( :symbol, 'unk2' ),
                        Token.new( :literal, 'xyz' ) 
                      ] )
                    ] )
    }, 'foo' )
   
    undefineds = Parser.check_symbols( grammar )
 
    assert_equal( 2, undefineds.size )
    assert( undefineds.include?( 'unknown1' ) )
    assert( undefineds.include?( 'unk2'  ) )

  end

  def test_already_defined_symbol
  
    stream = [
      #op="+" 
      Token.new( :symbol, 'op' ),
      Token.new( :equals ),
      Token.new( :literal, '+' ),
      Token.new( :newline ),

      #op="x" 
      Token.new( :symbol, 'op' ),
      Token.new( :equals ),
      Token.new( :literal, 'x' ),
      Token.new( :eof ),
    ]

    exception = assert_raise( RuntimeError ) { @parser.parse( stream ) }
    assert_equal( "Parser: symbol 'op' already defined", exception.message )
 
  end

  def test_not_defined_incremental
    stream = [
      #op=/"+" 
      Token.new( :symbol, 'op' ),
      Token.new( :eq_slash ),
      Token.new( :literal, '+' ),
      Token.new( :eof ),
    ]

    exception = assert_raise( RuntimeError ) { @parser.parse( stream ) }
    assert_equal( "Parser: incremental alternative: 'op' must be defined first", exception.message ) 
  end

  def test_repetitions
     stream = [
       #expr="begin" 3"repeat" "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '3' ),
       Token.new( :literal, 'repeat' ),    
       Token.new( :space ),
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    grammar = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ 
                    Token.new( :literal, 'begin' ),
                    Token.new( :symbol, 'expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      'expr_rpt1' => Rule.new( [ 
                      RuleAlt.new( [ 
                        Token.new( :literal, 'repeat' ),                                 
                        Token.new( :literal, 'repeat' ),                                 
                        Token.new( :literal, 'repeat' ),                                 
                       ] )
                    ] )
    }, 'expr' )

    assert_equal( grammar, @parser.parse( stream ) )

    stream2 = [
       #expr="begin" 3*3"repeat" "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '3' ),
       Token.new( :asterisk ),
       Token.new( :number, '3' ),
       Token.new( :literal, 'repeat' ),    
       Token.new( :space ),
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    assert_equal( grammar, @parser.parse( stream2 ) )

  end

  def test_repetitions_maximal
   
    stream3 = [
       #expr="begin" *3"repeat" "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :asterisk ),
       Token.new( :number, '3' ),
       Token.new( :literal, 'repeat' ),    
       Token.new( :space ),
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    grammar3 = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ 
                    Token.new( :literal, 'begin' ),
                    Token.new( :symbol, 'expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      'expr_rpt1' => Rule.new( [ 
                      RuleAlt.new( [ 
                        Token.new( :literal, '' ),                                 
                       ] ),
                      RuleAlt.new( [ 
                        Token.new( :literal, 'repeat' ),                                 
                       ] ),
                      RuleAlt.new( [ 
                        Token.new( :literal, 'repeat' ),                                 
                        Token.new( :literal, 'repeat' ),                                 
                      ] ),
                      RuleAlt.new( [ 
                        Token.new( :literal, 'repeat' ),                                 
                        Token.new( :literal, 'repeat' ),                                 
                        Token.new( :literal, 'repeat' ),                                 
                      ] )
                    ] )
    }, 'expr' )

    assert_equal( grammar3, @parser.parse( stream3 ) )

  end

  def test_repetitions_range
   
    stream4 = [
       #expr="begin" 2* 4"repeat" "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '2' ),
       Token.new( :asterisk ),
       Token.new( :space ),
       Token.new( :number, '4' ),
       Token.new( :literal, 'repeat' ),    
       Token.new( :space ),
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    grammar4 = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ 
                    Token.new( :literal, 'begin' ),
                    Token.new( :symbol, 'expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      'expr_rpt1' => Rule.new( [ 
                      RuleAlt.new( [ 
                        Token.new( :literal, 'repeat' ),                                 
                        Token.new( :literal, 'repeat' ),                                 
                      ] ),
                      RuleAlt.new( [ 
                        Token.new( :literal, 'repeat' ),                                 
                        Token.new( :literal, 'repeat' ),                                 
                        Token.new( :literal, 'repeat' ),                                 
                       ] ),
                      RuleAlt.new( [ 
                        Token.new( :literal, 'repeat' ),                                 
                        Token.new( :literal, 'repeat' ),                                 
                        Token.new( :literal, 'repeat' ),                                 
                        Token.new( :literal, 'repeat' ),                                 
                       ] )
                    ] )
    }, 'expr' )

    assert_equal( grammar4, @parser.parse( stream4 ) )

  end

  def test_repetitions_limit
   
    stream5 = [
       #expr="begin" 2*4000"repeat" "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '2' ),
       Token.new( :asterisk ),
       Token.new( :number, '4000' ),
       Token.new( :literal, 'repeat' ),    
       Token.new( :space ),
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    exception = assert_raise( RuntimeError ) { @parser.parse( stream5 ) }
    assert_equal( "Parser: max. allowed number of repetitions exceeded", exception.message )
  end

  def test_repetitions_infinity

    stream6 = [
       #expr="begin" 2*"repeat" "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '2' ),
       Token.new( :asterisk ),
       Token.new( :literal, 'repeat' ),    
       Token.new( :space ),
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    exception = assert_raise( RuntimeError ) { @parser.parse( stream6 ) }
    assert_equal( "Parser: unexpected token 'literal' when in rpt_2", exception.message )

  end

  def test_repetitions_sequence
   
    stream7 = [
       #expr="begin" 2 *4("seq1" "seq2") "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '2' ),
       Token.new( :space ),
       Token.new( :asterisk ),
       Token.new( :number, '4' ),
       Token.new( :seq_begin ),    
       Token.new( :literal, 'seq1' ),      
       Token.new( :space ),
       Token.new( :literal, 'seq2' ),      
       Token.new( :seq_end ),    
       Token.new( :space ),
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    grammar7 = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ 
                    Token.new( :literal, 'begin' ),
                    Token.new( :symbol, 'expr_rpt2' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      'expr_rpt2' => Rule.new( [ 
                      RuleAlt.new( [ 
                        Token.new( :symbol, 'expr_grp1' ),                                 
                        Token.new( :symbol, 'expr_grp1' ),                                 
                      ] ),
                      RuleAlt.new( [ 
                        Token.new( :symbol, 'expr_grp1' ),                                 
                        Token.new( :symbol, 'expr_grp1' ),                                 
                        Token.new( :symbol, 'expr_grp1' ),                                 
                       ] ),
                      RuleAlt.new( [ 
                        Token.new( :symbol, 'expr_grp1' ),                                 
                        Token.new( :symbol, 'expr_grp1' ),                                 
                        Token.new( :symbol, 'expr_grp1' ),                                 
                        Token.new( :symbol, 'expr_grp1' ),                                 
                       ] )
                    ] ),
       'expr_grp1' => Rule.new( [ 
                      RuleAlt.new( [ 
                         Token.new( :literal, 'seq1' ),
                         Token.new( :literal, 'seq2' ) 
                       ] )
                     ] )
                    
    }, 'expr' )

    assert_equal( grammar7, @parser.parse( stream7 ) )
  end

  def test_repetitions_morenumbers
  
    stream8 = [
       #expr="begin" 2*3*"repeat" "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '2' ),
       Token.new( :asterisk ),
       Token.new( :number, '3' ),
       Token.new( :asterisk ),
       Token.new( :literal, 'repeat' ),    
       Token.new( :space ),
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    exception = assert_raise( RuntimeError ) { @parser.parse( stream8 ) }
    assert_equal( "Parser: unexpected token 'literal' when in rpt_2", exception.message )
  end

  def test_repetitions_minmax
    stream9 = [
       #expr="begin" 6*4"repeat" "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '6' ),
       Token.new( :asterisk ),
       Token.new( :number, '4' ),
       Token.new( :literal, 'repeat' ),    
       Token.new( :space ),
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    exception = assert_raise( RuntimeError ) { @parser.parse( stream9 ) }
    assert_equal( "Parser: min>max in repetition", exception.message )
   
  end

  def test_repetitions_hexdig
   
    stream = [
       #expr = HEXDIG "begin" 4HEXDIG "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :space ),
       Token.new( :_hexdig ),        
       Token.new( :space ),      
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '4' ),
       Token.new( :_hexdig ),    
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    grammar = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ 
                    Token.new( :symbol, '_hexdig' ),                              
                    Token.new( :literal, 'begin' ),
                    Token.new( :symbol, 'expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      'expr_rpt1' => Rule.new( [ 
                      RuleAlt.new( [ 
                        Token.new( :symbol, '_hexdig' ),                                 
                        Token.new( :symbol, '_hexdig' ),                                 
                        Token.new( :symbol, '_hexdig' ),                                 
                        Token.new( :symbol, '_hexdig' ),                                 
                       ] )
                    ] ),
      '_hexdig' => Rule.new( [ 
                      RuleAlt.new( [ Token.new( :literal, '0' ) ] ),
                      RuleAlt.new( [ Token.new( :literal, '1' ) ] ), 
                      RuleAlt.new( [ Token.new( :literal, '2' ) ] ), 
                      RuleAlt.new( [ Token.new( :literal, '3' ) ] ), 
                      RuleAlt.new( [ Token.new( :literal, '4' ) ] ), 
                      RuleAlt.new( [ Token.new( :literal, '5' ) ] ), 
                      RuleAlt.new( [ Token.new( :literal, '6' ) ] ), 
                      RuleAlt.new( [ Token.new( :literal, '7' ) ] ), 
                      RuleAlt.new( [ Token.new( :literal, '8' ) ] ),
                      RuleAlt.new( [ Token.new( :literal, '9' ) ] ),                        
                      RuleAlt.new( [ Token.new( :literal, 'A' ) ] ), 
                      RuleAlt.new( [ Token.new( :literal, 'B' ) ] ), 
                      RuleAlt.new( [ Token.new( :literal, 'C' ) ] ),
                      RuleAlt.new( [ Token.new( :literal, 'D' ) ] ), 
                      RuleAlt.new( [ Token.new( :literal, 'E' ) ] ), 
                      RuleAlt.new( [ Token.new( :literal, 'F' ) ] )
                     ] )
                    
    }, 'expr' )

    assert_equal( grammar, @parser.parse( stream ) )
  end

  def test_repetitions_alpha
   
    stream = [
       #expr = ALPHA "begin" 4ALPHA "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :space ),
       Token.new( :_alpha ),        
       Token.new( :space ),      
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '4' ),
       Token.new( :_alpha ),    
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    rule = Rule.new
    ('A'..'Z').each {|i| rule.push RuleAlt.new([Token.new(:literal, i)]) }
    ('a'..'z').each {|i| rule.push RuleAlt.new([Token.new(:literal, i)]) }   
    grammar = @parser.parse( stream ) 
    assert_equal( rule, grammar['_alpha'] )

  end

  def test_repetitions_bit
   
    stream = [
       #expr = BIT "begin" 4BIT "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :space ),
       Token.new( :_bit ),        
       Token.new( :space ),      
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '4' ),
       Token.new( :_bit ),    
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    grammar = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ 
                    Token.new( :symbol, '_bit' ),                              
                    Token.new( :literal, 'begin' ),
                    Token.new( :symbol, 'expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      'expr_rpt1' => Rule.new( [ 
                      RuleAlt.new( [ 
                        Token.new( :symbol, '_bit' ),                                 
                        Token.new( :symbol, '_bit' ),                                 
                        Token.new( :symbol, '_bit' ),                                 
                        Token.new( :symbol, '_bit' ),                                 
                       ] )
                    ] ),
      '_bit' => Rule.new( [ 
                      RuleAlt.new( [ Token.new( :literal, '0' ) ] ),
                      RuleAlt.new( [ Token.new( :literal, '1' ) ] )
                     ] )
                    
    }, 'expr' )

    assert_equal( grammar, @parser.parse( stream ) )
  end
 
  def test_repetitions_digit
   
    stream = [
       #expr = DIGIT "begin" 4DIGIT "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :space ),
       Token.new( :_digit ),        
       Token.new( :space ),      
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '4' ),
       Token.new( :_digit ),    
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    grammar = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ 
                    Token.new( :symbol, '_digit' ),                              
                    Token.new( :literal, 'begin' ),
                    Token.new( :symbol, 'expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      'expr_rpt1' => Rule.new( [ 
                      RuleAlt.new( [ 
                        Token.new( :symbol, '_digit' ),                                 
                        Token.new( :symbol, '_digit' ),                                 
                        Token.new( :symbol, '_digit' ),                                 
                        Token.new( :symbol, '_digit' ),                                 
                       ] )
                    ] ),
      '_digit' => Rule.new( [ 
                      RuleAlt.new( [ Token.new( :literal, '0' ) ] ),
                      RuleAlt.new( [    Token.new( :literal, '1' ) ] ), 
                      RuleAlt.new( [    Token.new( :literal, '2' ) ] ), 
                      RuleAlt.new( [    Token.new( :literal, '3' ) ] ), 
                      RuleAlt.new( [    Token.new( :literal, '4' ) ] ), 
                      RuleAlt.new( [    Token.new( :literal, '5' ) ] ), 
                      RuleAlt.new( [    Token.new( :literal, '6' ) ] ), 
                      RuleAlt.new( [    Token.new( :literal, '7' ) ] ), 
                      RuleAlt.new( [    Token.new( :literal, '8' ) ] ), 
                      RuleAlt.new( [    Token.new( :literal, '9' ) ] )
                  ] )
                    
    }, 'expr' )

    assert_equal( grammar, @parser.parse( stream ) )
  end

  def test_repetitions_cr
   
    stream = [
       #expr = CR "begin" 4CR "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :space ),
       Token.new( :_cr ),        
       Token.new( :space ),      
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '4' ),
       Token.new( :_cr ),    
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    grammar = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ 
                    Token.new( :literal, "\r" ),                              
                    Token.new( :literal, 'begin' ),
                    Token.new( :symbol, 'expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      'expr_rpt1' => Rule.new( [ 
                      RuleAlt.new( [ 
                        Token.new( :literal, "\r" ),                                 
                        Token.new( :literal, "\r" ),                                 
                        Token.new( :literal, "\r" ),                                 
                        Token.new( :literal, "\r" ),                                 
                       ] )
                    ] )                    
    }, 'expr' )

    assert_equal( grammar, @parser.parse( stream ) )
  end

  def test_repetitions_lf
   
    stream = [
       #expr = LF "begin" 4LF "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :space ),
       Token.new( :_lf ),        
       Token.new( :space ),      
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '4' ),
       Token.new( :_lf ),    
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    grammar = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ 
                    Token.new( :literal, "\n" ),                              
                    Token.new( :literal, 'begin' ),
                    Token.new( :symbol, 'expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      'expr_rpt1' => Rule.new( [ 
                      RuleAlt.new( [ 
                        Token.new( :literal, "\n" ),                                 
                        Token.new( :literal, "\n" ),                                 
                        Token.new( :literal, "\n" ),                                 
                        Token.new( :literal, "\n" ),                                 
                       ] )
                    ] )                    
    }, 'expr' )

    assert_equal( grammar, @parser.parse( stream ) )
  end

  def test_repetitions_crlf
   
    stream = [
       #expr = CRLF "begin" 4CRLF "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :space ),
       Token.new( :_crlf ),        
       Token.new( :space ),      
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '4' ),
       Token.new( :_crlf ),    
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    grammar = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ 
                    Token.new( :literal, "\r\n" ),                              
                    Token.new( :literal, 'begin' ),
                    Token.new( :symbol, 'expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      'expr_rpt1' => Rule.new( [ 
                      RuleAlt.new( [ 
                        Token.new( :literal, "\r\n" ),                                 
                        Token.new( :literal, "\r\n" ),                                 
                        Token.new( :literal, "\r\n" ),                                 
                        Token.new( :literal, "\r\n" ),                                 
                       ] )
                    ] )                    
    }, 'expr' )

    assert_equal( grammar, @parser.parse( stream ) )
  end

  def test_repetitions_sp
   
    stream = [
       #expr = SP "begin" 2SP "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :space ),
       Token.new( :_sp ),        
       Token.new( :space ),      
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '2' ),
       Token.new( :_sp ),    
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    grammar = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ 
                    Token.new( :literal, " " ),                              
                    Token.new( :literal, 'begin' ),
                    Token.new( :symbol, 'expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      'expr_rpt1' => Rule.new( [ 
                      RuleAlt.new( [ 
                        Token.new( :literal, " " ),                                 
                        Token.new( :literal, " " ),                                 
                       ] )
                    ] )                    
    }, 'expr' )

    assert_equal( grammar, @parser.parse( stream ) )
  end
 
  def test_repetitions_dquote
   
    stream = [
       #expr = DQUOTE "begin" DQUOTE "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :space ),
       Token.new( :_dquote ),        
       Token.new( :space ),      
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '2' ),
       Token.new( :_dquote ),    
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    grammar = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ 
                    Token.new( :literal, "\"" ),                              
                    Token.new( :literal, 'begin' ),
                    Token.new( :symbol, 'expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      'expr_rpt1' => Rule.new( [ 
                      RuleAlt.new( [ 
                        Token.new( :literal, "\"" ),                                 
                        Token.new( :literal, "\"" ),                                 
                       ] )
                    ] )                    
    }, 'expr' )

    assert_equal( grammar, @parser.parse( stream ) )
  end
  
end

