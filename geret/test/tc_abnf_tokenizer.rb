#!/usr/bin/ruby

require 'test/unit'
require 'lib/abnf_tokenizer'

class TC_AbnfTokenizer < Test::Unit::TestCase

  def setup
    @example1 = <<ABNF_TEXT
;start symbol
start-symbol = <foo> [bar] (foo2 bar)

foo          = 1*14DIGIT / 42*VCHAR / 5CHAR ["-" *4HEXDIG] *4HTAB
foo          =/ 1*8(DIGIT/ALPHA) CR LF ; some comment

   ;comment
<bar> =  %d13.10.33 %x0D / %x3f-aB %b100101;wp =100
bar =/ DQUOTE WSP LWSP OCTET CTL CRLF BIT;

foo2 = "text" foo "text1" "" SP "text3" 

ABNF_TEXT
  end

  def test_token
    t = Abnf::Token.new( :comment, 'text' )
    assert_equal( t.type, :comment )
    assert_equal( t.data, 'text' )

    assert( Abnf::Token.new( :symbol, 'text' ) == Abnf::Token.new( :symbol, 'text' ) )
    assert( Abnf::Token.new( :comment, 'text' ) != Abnf::Token.new( :symbol, 'text' ) )
    assert( Abnf::Token.new( :symbol, 'text' ) != Abnf::Token.new( :symbol, 'text2' ) ) 
    assert( Abnf::Token.new( :comment, 'text' ) != Abnf::Token.new( :symbol, 'text2' ) )

    assert( Abnf::Token.new( :space ) == Abnf::Token.new( :space ) )
    assert( Abnf::Token.new( :equals ) != Abnf::Token.new( :space ) )
  end

  def test_basic
    tokenizer = Abnf::Tokenizer.new
    token_stream = tokenizer.tokenize(  @example1 )

    #;start symbol
    assert_equal( Abnf::Token.new( :comment, 'start symbol' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :newline ), token_stream.shift ) 

    #start-symbol = <foo> [bar] (foo2 bar)
    assert_equal( Abnf::Token.new( :symbol, 'start-symbol' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )
    assert_equal( Abnf::Token.new( :equals ), token_stream.shift ) 
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )
    assert_equal( Abnf::Token.new( :symbol, 'foo' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )
    assert_equal( Abnf::Token.new( :opt_begin ), token_stream.shift )
    assert_equal( Abnf::Token.new( :symbol, 'bar' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :opt_end ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )
    assert_equal( Abnf::Token.new( :seq_begin ), token_stream.shift )
    assert_equal( Abnf::Token.new( :symbol, 'foo2' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )   
    assert_equal( Abnf::Token.new( :symbol, 'bar' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :seq_end ), token_stream.shift )
    assert_equal( Abnf::Token.new( :newline ), token_stream.shift ) 

    assert_equal( Abnf::Token.new( :newline ), token_stream.shift )    

    #foo          = 1*14DIGIT / 42*VCHAR / 5CHAR ["-" *4HEXDIG] *4HTAB
    assert_equal( Abnf::Token.new( :symbol, 'foo' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )
    assert_equal( Abnf::Token.new( :equals ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )
    assert_equal( Abnf::Token.new( :number, '1' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :asterisk ), token_stream.shift )
    assert_equal( Abnf::Token.new( :number, '14' ), token_stream.shift )   
    assert_equal( Abnf::Token.new( :_digit ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )   
    assert_equal( Abnf::Token.new( :slash ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )
    assert_equal( Abnf::Token.new( :number, '42' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :asterisk ), token_stream.shift )  
    assert_equal( Abnf::Token.new( :_vchar ), token_stream.shift )   
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )  
    assert_equal( Abnf::Token.new( :slash ), token_stream.shift )  
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )   
    assert_equal( Abnf::Token.new( :number, '5' ), token_stream.shift )   
    assert_equal( Abnf::Token.new( :_char ), token_stream.shift )  
    assert_equal( Abnf::Token.new( :space ), token_stream.shift ) 
    assert_equal( Abnf::Token.new( :opt_begin ), token_stream.shift )
    assert_equal( Abnf::Token.new( :literal, '-' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )    
    assert_equal( Abnf::Token.new( :asterisk ), token_stream.shift )  
    assert_equal( Abnf::Token.new( :number, '4' ), token_stream.shift )   
    assert_equal( Abnf::Token.new( :_hexdig ), token_stream.shift )
    assert_equal( Abnf::Token.new( :opt_end ), token_stream.shift )   
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )
    assert_equal( Abnf::Token.new( :asterisk ), token_stream.shift )   
    assert_equal( Abnf::Token.new( :number, '4' ), token_stream.shift )   
    assert_equal( Abnf::Token.new( :_htab ), token_stream.shift )
    assert_equal( Abnf::Token.new( :newline ), token_stream.shift ) 
    
    #foo          =/ 1*8(DIGIT/ALPHA) CR LF ; some comment
    assert_equal( Abnf::Token.new( :symbol, 'foo' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )
    assert_equal( Abnf::Token.new( :equals ), token_stream.shift )
    assert_equal( Abnf::Token.new( :slash ), token_stream.shift )  
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )
    assert_equal( Abnf::Token.new( :number, '1' ), token_stream.shift )   
    assert_equal( Abnf::Token.new( :asterisk ), token_stream.shift )  
    assert_equal( Abnf::Token.new( :number, '8' ), token_stream.shift )  
    assert_equal( Abnf::Token.new( :seq_begin ), token_stream.shift )
    assert_equal( Abnf::Token.new( :_digit ), token_stream.shift )
    assert_equal( Abnf::Token.new( :slash ), token_stream.shift )     
    assert_equal( Abnf::Token.new( :_alpha ), token_stream.shift )  
    assert_equal( Abnf::Token.new( :seq_end ), token_stream.shift )   
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )   
    assert_equal( Abnf::Token.new( :_cr ), token_stream.shift ) 
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )      
    assert_equal( Abnf::Token.new( :_lf ), token_stream.shift )    
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )      
    assert_equal( Abnf::Token.new( :comment, ' some comment' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :newline ), token_stream.shift ) 

    assert_equal( Abnf::Token.new( :newline ), token_stream.shift ) 

    #;comment
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )       
    assert_equal( Abnf::Token.new( :comment, 'comment' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :newline ), token_stream.shift ) 
   
    #<bar> =  %d13.10.33 %x0D / %x3f-aB %b100101;wp =100
    assert_equal( Abnf::Token.new( :symbol, 'bar' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )       
    assert_equal( Abnf::Token.new( :equals ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )
    assert_equal( Abnf::Token.new( :entity_dec, '13' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :dot ), token_stream.shift )
    assert_equal( Abnf::Token.new( :entity_dec, '10' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :dot ), token_stream.shift )   
    assert_equal( Abnf::Token.new( :entity_dec, '33' ), token_stream.shift )   
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )
    assert_equal( Abnf::Token.new( :entity_hex, '0D' ), token_stream.shift )   
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )
    assert_equal( Abnf::Token.new( :slash ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )  
    assert_equal( Abnf::Token.new( :entity_hex, '3f' ), token_stream.shift )   
    assert_equal( Abnf::Token.new( :dash ), token_stream.shift )  
    assert_equal( Abnf::Token.new( :entity_hex, 'aB' ), token_stream.shift )   
    assert_equal( Abnf::Token.new( :space ), token_stream.shift ) 
    assert_equal( Abnf::Token.new( :entity_bin, '100101' ), token_stream.shift )  
    assert_equal( Abnf::Token.new( :comment, 'wp =100' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :newline ), token_stream.shift ) 

    #bar =/ DQUOTE WSP LWSP OCTET CTL CRLF BIT;
    assert_equal( Abnf::Token.new( :symbol, 'bar' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )       
    assert_equal( Abnf::Token.new( :equals ), token_stream.shift )
    assert_equal( Abnf::Token.new( :slash ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )
    assert_equal( Abnf::Token.new( :_dquote ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )  
    assert_equal( Abnf::Token.new( :_wsp ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )  
    assert_equal( Abnf::Token.new( :_lwsp ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )  
    assert_equal( Abnf::Token.new( :_octet ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )  
    assert_equal( Abnf::Token.new( :_ctl ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )  
    assert_equal( Abnf::Token.new( :_crlf ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )  
    assert_equal( Abnf::Token.new( :_bit ), token_stream.shift )
    assert_equal( Abnf::Token.new( :comment, '' ), token_stream.shift )   
    assert_equal( Abnf::Token.new( :newline ), token_stream.shift )  
    
    assert_equal( Abnf::Token.new( :newline ), token_stream.shift ) 

    #foo2 = "text" foo "text1" "" SP "text3" 
    assert_equal( Abnf::Token.new( :symbol, 'foo2' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )       
    assert_equal( Abnf::Token.new( :equals ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )
    assert_equal( Abnf::Token.new( :literal, 'text' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )    
    assert_equal( Abnf::Token.new( :symbol, 'foo' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )       
    assert_equal( Abnf::Token.new( :literal, 'text1' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )    
    assert_equal( Abnf::Token.new( :literal, '' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )    
    assert_equal( Abnf::Token.new( :_sp ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift )    
    assert_equal( Abnf::Token.new( :literal, 'text3' ), token_stream.shift )
    assert_equal( Abnf::Token.new( :space ), token_stream.shift ) 
    assert_equal( Abnf::Token.new( :newline ), token_stream.shift )  

    assert_equal( Abnf::Token.new( :newline ), token_stream.shift )  
  end

  def test_unexpected
    exception = assert_raise( RuntimeError ) { Abnf::Tokenizer.new.tokenize('wrong @chars') }
    assert_equal( "Tokenizer: unexpected tokens near '@chars'", exception.message )
  end

 
end

