#!/usr/bin/ruby

require 'test/unit'
require 'lib/abnf_file'

class TC_AbnfFile < Test::Unit::TestCase

  def setup
    @grammar_ref = Grammar.new( { 
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
    grammar_file = AbnfFile.new 'test/data/simple_file.abnf'   
    assert_equal( @grammar_ref, grammar_file )
  end

  def test_filename_attr
    grammar_file = AbnfFile.new
    assert_equal( nil, grammar_file.filename )
    assert_equal( [], grammar_file.symbols )
    assert_equal( nil, grammar_file.start_symbol )

    grammar_file.filename = 'test/data/simple_file.abnf'
    assert_equal( 'test/data/simple_file.abnf', grammar_file.filename )
    assert_equal( @grammar_ref, grammar_file )  

    grammar_file.filename = nil
    assert_equal( nil, grammar_file.filename )
    assert_equal( [], grammar_file.symbols )
    assert_equal( nil, grammar_file.start_symbol )
  end

end

