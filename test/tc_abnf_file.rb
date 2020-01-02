
$LOAD_PATH << '.' unless $LOAD_PATH.include? '.'

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
    grammar_file = Abnf::File.new 'test/data/simple_file.abnf'   
    assert_equal( @grammar_ref, grammar_file )
  end

  def test_filename_attr
    grammar_file = Abnf::File.new
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

  def test_validating_abnf_file

    grammar = Abnf::FileLoader.new 'test/data/simple_file.abnf' 

    assert_equal( nil, grammar['expr'].recursivity )   
    assert_equal( nil, grammar['op'].sn_altering )   
    assert_equal( nil, grammar['expr'].last.arity )   
    assert_equal( nil, grammar['expr'].min_depth )   

    grammar_analyzed = Abnf::File.new 'test/data/simple_file.abnf'    
  
    assert_equal( :cyclic, grammar_analyzed['expr'].recursivity )   
    assert_equal( :nodal, grammar_analyzed['op'].sn_altering )      
    assert_equal( 3, grammar_analyzed['expr'].last.arity )      
    assert_equal( 2, grammar_analyzed['expr'].min_depth )  
   
  end

  def test_start_space_bug
    grammar_file = Abnf::File.new

    grammar_file.filename = 'test/data/start_space_bug.abnf'
    assert_equal( @grammar_ref, grammar_file )
  end

end

