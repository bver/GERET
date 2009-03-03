#!/usr/bin/ruby

require 'test/unit'
require 'lib/generators'
require 'lib/random'

class TC_Generators < Test::Unit::TestCase

  def setup
    @grammar = Mapper::Grammar.new( { 
      'expr' => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'x' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'y' ) ] ),
                  Mapper::RuleAlt.new( [ 
                    Mapper::Token.new( :literal, '(' ), 
                    Mapper::Token.new( :symbol, 'expr', 42 ),
                    Mapper::Token.new( :symbol, 'op', 4 ),                  
                    Mapper::Token.new( :symbol, 'expr', 12 ),                   
                    Mapper::Token.new( :literal, ')' ) 
                  ] )
                ] ),

       'op'  => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '+' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '*' ) ] )
                ] )
    }, 'expr' )

  end

  def test_depth_first_generate
    m = Mapper::GeneratorDepthFirst.new @grammar
    r = Random.new :deterministic

    r.set_predef [0,0,  0,0,  0,0,  0,0,  1,0,  1,0,  0,0,  0,0,  1,0,  0,0]
    m.random = r
    gen = [2, 2, 2, 0, 1, 1, 0, 0, 1, 0] 
    assert_equal( gen, m.generate_full( 3 ) )
    assert_equal( '(((x*y)+x)*x)', m.phenotype(gen) )
    assert_equal( 3, m.max_codon_base ) 

    m.max_codon_base = 10
    assert_equal( 10, m.max_codon_base ) 
    r.set_predef [0,0,    0,2,  0,0,   0,1,  1,0,    1,1,  0,0,  0,0,    1,2,    0,2]
    m.random = r
    assert_equal([  2,  2+2*3,    2, 0+1*3,    1,  1+1*3,    0,    0,  1+2*2,  0+2*3], 
                 m.generate_full( 3 ) )
    assert_equal( '(((x*y)+x)*x)', m.phenotype(gen) )

    #r.set_predef [] 
    #assert_equal( [], m.generate_grow( 3 ) )
  end

end

