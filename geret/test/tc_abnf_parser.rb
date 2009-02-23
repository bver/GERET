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
    #symb = "begin" _symb_grp1 "end"
    #_symb_grp1 = "alt1"
    #_symb_grp1 =/ "alt2"
    #_symb_grp1 =/ "alt3a" "alt3b"

    grammar = Grammar.new( { 
      'symb' => Rule.new( [ 
                  RuleAlt.new( [ 
                    Token.new( :literal, 'begin' ), 
                    Token.new( :symbol, '_symb_grp1' ),
                    Token.new( :literal, 'end' ) 
                 ] )
               ] ),
      '_symb_grp1' => Rule.new( [ 
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
                    Token.new( :symbol, '_foo_opt1' ),
                    Token.new( :literal, 'end' ) 
                 ] )
               ] ),

      '_foo_opt1' => Rule.new( [ 
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
                    Token.new( :symbol, '_foo_opt1' ),
                    Token.new( :symbol, 'unknown1' ) 
                 ] )
               ] ),

      '_foo_opt1' => Rule.new( [ 
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
                    Token.new( :symbol, '_expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      '_expr_rpt1' => Rule.new( [ 
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
                    Token.new( :symbol, '_expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      '_expr_rpt1' => Rule.new( [ 
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
                    Token.new( :symbol, '_expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      '_expr_rpt1' => Rule.new( [ 
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
       #expr="begin" 2*200"repeat" "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '2' ),
       Token.new( :asterisk ),
       Token.new( :number, '200' ),
       Token.new( :literal, 'repeat' ),    
       Token.new( :space ),
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    assert_equal( 100, @parser.max_repetitions )

    exception = assert_raise( RuntimeError ) { @parser.parse( stream5 ) }
    assert_equal( "Parser: max. allowed number of repetitions (100) exceeded", exception.message )

    @parser.max_repetitions = 200
    assert_equal( 200, @parser.max_repetitions )   
    @parser.parse( stream5 ) # no error

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
                    Token.new( :symbol, '_expr_rpt2' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      '_expr_rpt2' => Rule.new( [ 
                      RuleAlt.new( [ 
                        Token.new( :symbol, '_expr_grp1' ),                                 
                        Token.new( :symbol, '_expr_grp1' ),                                 
                      ] ),
                      RuleAlt.new( [ 
                        Token.new( :symbol, '_expr_grp1' ),                                 
                        Token.new( :symbol, '_expr_grp1' ),                                 
                        Token.new( :symbol, '_expr_grp1' ),                                 
                       ] ),
                      RuleAlt.new( [ 
                        Token.new( :symbol, '_expr_grp1' ),                                 
                        Token.new( :symbol, '_expr_grp1' ),                                 
                        Token.new( :symbol, '_expr_grp1' ),                                 
                        Token.new( :symbol, '_expr_grp1' ),                                 
                       ] )
                    ] ),
       '_expr_grp1' => Rule.new( [ 
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
                    Token.new( :symbol, '_expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      '_expr_rpt1' => Rule.new( [ 
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
                    Token.new( :symbol, '_expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      '_expr_rpt1' => Rule.new( [ 
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
                    Token.new( :symbol, '_expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      '_expr_rpt1' => Rule.new( [ 
                      RuleAlt.new( [ 
                        Token.new( :symbol, '_digit' ),                                 
                        Token.new( :symbol, '_digit' ),                                 
                        Token.new( :symbol, '_digit' ),                                 
                        Token.new( :symbol, '_digit' ),                                 
                       ] )
                    ] ),
      '_digit' => Rule.new( [ 
                      RuleAlt.new( [ Token.new( :literal, '0' ) ] ),
                      RuleAlt.new( [ Token.new( :literal, '1' ) ] ), 
                      RuleAlt.new( [ Token.new( :literal, '2' ) ] ), 
                      RuleAlt.new( [ Token.new( :literal, '3' ) ] ), 
                      RuleAlt.new( [ Token.new( :literal, '4' ) ] ), 
                      RuleAlt.new( [ Token.new( :literal, '5' ) ] ), 
                      RuleAlt.new( [ Token.new( :literal, '6' ) ] ), 
                      RuleAlt.new( [ Token.new( :literal, '7' ) ] ), 
                      RuleAlt.new( [ Token.new( :literal, '8' ) ] ), 
                      RuleAlt.new( [ Token.new( :literal, '9' ) ] )
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
                    Token.new( :symbol, '_expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      '_expr_rpt1' => Rule.new( [ 
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
                    Token.new( :symbol, '_expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      '_expr_rpt1' => Rule.new( [ 
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
                    Token.new( :symbol, '_expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      '_expr_rpt1' => Rule.new( [ 
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
                    Token.new( :symbol, '_expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      '_expr_rpt1' => Rule.new( [ 
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
                    Token.new( :symbol, '_expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      '_expr_rpt1' => Rule.new( [ 
                        RuleAlt.new( [ 
                          Token.new( :literal, "\"" ),                                 
                          Token.new( :literal, "\"" ),                                 
                        ] )
                      ] )                    
    }, 'expr' )

    assert_equal( grammar, @parser.parse( stream ) )
  end
  
  def test_repetitions_htab
   
    stream = [
       #expr = SP "begin" 2SP "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :space ),
       Token.new( :_htab ),        
       Token.new( :space ),      
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '2' ),
       Token.new( :_htab ),    
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    grammar = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ 
                    Token.new( :literal, "\t" ),                              
                    Token.new( :literal, 'begin' ),
                    Token.new( :symbol, '_expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      '_expr_rpt1' => Rule.new( [ 
                        RuleAlt.new( [ 
                          Token.new( :literal, "\t" ),                                 
                          Token.new( :literal, "\t" ),                                 
                        ] )
                      ] )                    
    }, 'expr' )

    assert_equal( grammar, @parser.parse( stream ) )
  end
 
  def test_repetitions_char
   
    stream = [
       #expr =CHAR 2CHAR
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :_char ),              
       Token.new( :space ),
       Token.new( :number, '2' ),
       Token.new( :_char ),        
       Token.new( :eof )
    ]

    rule = Rule.new
    ( 0x01..0x7F ).each do |i| 
      data = ''
      data << i
      rule.push RuleAlt.new([Token.new(:literal, data)]) 
    end
    grammar = @parser.parse( stream ) 
    assert_equal( rule, grammar['_char'] )

  end

  def test_repetitions_ctl
   
    stream = [
       #expr =CTL 2CTL
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :_ctl ),              
       Token.new( :space ),
       Token.new( :number, '2' ),
       Token.new( :_ctl ),        
       Token.new( :eof )
    ]

    rule = Rule.new
    (0x00..0x1F).each do |i| 
      data = ''
      data << i
      rule.push RuleAlt.new([Token.new(:literal, data )]) 
    end
    data = ''
    data << 0x7F
    rule.push RuleAlt.new([Token.new(:literal, data)])
    grammar = @parser.parse( stream ) 
    assert_equal( rule, grammar['_ctl'] )

  end

  def test_repetitions_vchar
   
    stream = [
       #expr =VCHAR 2VCHAR
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :_vchar ),              
       Token.new( :space ),
       Token.new( :number, '2' ),
       Token.new( :_vchar ),        
       Token.new( :eof )
    ]

    rule = Rule.new
    ( 0x21..0x7E ).each do |i| 
      data = ''
      data << i
      rule.push RuleAlt.new([Token.new(:literal, data)]) 
    end
    grammar = @parser.parse( stream ) 
    assert_equal( rule, grammar['_vchar'] )

  end

  def test_repetitions_octet
   
    stream = [
       #expr =OCTET 2OCTET 
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :_octet ),              
       Token.new( :space ),
       Token.new( :number, '2' ),
       Token.new( :_octet ),        
       Token.new( :eof )
    ]

    rule = Rule.new
    ( 0x00..0xFF ).each do |i| 
      data = ''
      data << i
      rule.push RuleAlt.new([Token.new(:literal, data)]) 
    end
    grammar = @parser.parse( stream ) 
    assert_equal( rule, grammar['_octet'] )

  end
 
  def test_repetitions_wsp
   
    stream = [
       #expr = WSP "begin" 3WSP "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :space ),
       Token.new( :_wsp ),        
       Token.new( :space ),      
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '3' ),
       Token.new( :_wsp ),    
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    grammar = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ 
                    Token.new( :symbol, '_wsp' ),                              
                    Token.new( :literal, 'begin' ),
                    Token.new( :symbol, '_expr_rpt1' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      '_expr_rpt1' => Rule.new( [ 
                        RuleAlt.new( [ 
                          Token.new( :symbol, '_wsp' ),                                 
                          Token.new( :symbol, '_wsp' ),                                 
                          Token.new( :symbol, '_wsp' ),                                 
                        ] )
                      ] ),
      '_wsp' => Rule.new( [ 
                      RuleAlt.new( [ Token.new( :literal, " " ) ] ),
                      RuleAlt.new( [ Token.new( :literal, "\t" ) ] ), 
                ] )
                    
    }, 'expr' )

    assert_equal( grammar, @parser.parse( stream ) )
  end

 def test_underscore_symbol
    stream = [
       #_expr="end"
       Token.new( :symbol, '_expr' ),
       Token.new( :equals ),
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    exception = assert_raise( RuntimeError ) { @parser.parse( stream ) }
    assert_equal( "Parser: external symbols cannot start with the underscore", exception.message )
  end

  def test_repetition_hexadecimal_binary_decimal_range
   
    stream = [
       #expr = %x30-32 "begin" 3%x63-64 "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :space ),
       Token.new( :range_hex, '30-32' ),        
       Token.new( :space ),      
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '3' ),
       Token.new( :range_hex, '63-64' ),    
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    grammar = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ 
                    Token.new( :symbol, '_expr_rng1' ),                              
                    Token.new( :literal, 'begin' ),
                    Token.new( :symbol, '_expr_rpt3' ),
                    Token.new( :literal, 'end' )
                  ] )
                ] ),
      '_expr_rng1' => Rule.new( [ 
                        RuleAlt.new( [ Token.new( :literal, '0' ) ] ),
                        RuleAlt.new( [ Token.new( :literal, '1' ) ] ),                              
                        RuleAlt.new( [ Token.new( :literal, '2' ) ] ), 
                      ] ),
      '_expr_rng2' => Rule.new( [ 
                        RuleAlt.new( [ Token.new( :literal, 'c' ) ] ),
                        RuleAlt.new( [ Token.new( :literal, 'd' ) ] ),                              
                      ] ),
      '_expr_rpt3' => Rule.new( [ 
                        RuleAlt.new( [ 
                          Token.new( :symbol, '_expr_rng2' ),
                          Token.new( :symbol, '_expr_rng2' ),
                          Token.new( :symbol, '_expr_rng2' )
                        ] ),
                      ] )
    }, 'expr' )

    assert_equal( grammar, @parser.parse( stream ) )

    stream2 = [
       #expr = %d48-50 "begin" 3%d99-100 "end"
       Token.new( :symbol, 'expr' ),
       Token.new( :equals ),
       Token.new( :space ),
       Token.new( :range_dec, '48-50' ),        
       Token.new( :space ),      
       Token.new( :literal, 'begin' ),
       Token.new( :space ),
       Token.new( :number, '3' ),
       Token.new( :range_dec, '99-100' ),    
       Token.new( :literal, 'end' ),
       Token.new( :eof )
    ]

    assert_equal( grammar, @parser.parse( stream2 ) )

  end

  def test_values_concat
    stream1 = [
      #expr=%d50.49.48 2%d115
      Token.new( :symbol, 'expr' ),
      Token.new( :equals ),
      Token.new( :entity_dec, '50' ), #2
      Token.new( :dot ), 
      Token.new( :entity_dec, '49' ), #1
      Token.new( :dot ),
      Token.new( :entity_dec, '48' ), #0   
      Token.new( :space ),
      Token.new( :number, '2' ),
      Token.new( :entity_dec, '115' ), #c 
      Token.new( :eof )
    ]

    grammar = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ 
                    Token.new( :literal, '2' ),
                    Token.new( :literal, '1' ),
                    Token.new( :literal, '0' ),
                    Token.new( :symbol, '_expr_rpt1' ),
                  ] )
                ] ),
     '_expr_rpt1' => Rule.new( [ 
                      RuleAlt.new( [                    
                    Token.new( :literal, 's' ),                   
                    Token.new( :literal, 's' )                   
                  ] )
                ] )
    }, 'expr' )

    assert_equal( grammar, @parser.parse( stream1 ) )

    stream2 = [
      #expr=%h32.31.30 2%h73
      Token.new( :symbol, 'expr' ),
      Token.new( :equals ),
      Token.new( :entity_hex, '32' ), #2
      Token.new( :dot ), 
      Token.new( :entity_hex, '31' ), #1
      Token.new( :dot ),
      Token.new( :entity_hex, '30' ), #0   
      Token.new( :space ),
      Token.new( :number, '2' ),
      Token.new( :entity_hex, '73' ), #c 
      Token.new( :eof )
    ]

    assert_equal( grammar, @parser.parse( stream2 ) )

    stream3 = [
      #expr=%b110010.110001.110000 2%b1110011
      Token.new( :symbol, 'expr' ),
      Token.new( :equals ),
      Token.new( :entity_bin, '110010' ), #2
      Token.new( :dot ), 
      Token.new( :entity_bin, '110001' ), #1
      Token.new( :dot ),
      Token.new( :entity_bin, '110000' ), #0   
      Token.new( :space ),
      Token.new( :number, '2' ),
      Token.new( :entity_bin, '1110011' ), #c 
      Token.new( :eof )
    ]

    assert_equal( grammar, @parser.parse( stream3 ) )
   
  end

end

