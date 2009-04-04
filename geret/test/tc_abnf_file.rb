#!/usr/bin/ruby

require 'test/unit'
require 'lib/abnf_file'

class TC_AbnfFile < Test::Unit::TestCase

  def test_basic
    grammar_ref = Grammar.new( { 
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
   
    grammar_file = AbnfFile.new 'test/data/simple_file.abnf'   
    
    assert_equal( grammar_ref, grammar_file )
  end
end

