#!/usr/bin/ruby

require 'test/unit'
require 'lib/mappers'

class TC_Mappers < Test::Unit::TestCase

  def setup
    @grammar = Mapper::Grammar.new( { 
      'expr' => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'x' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'y' ) ] ),
                  Mapper::RuleAlt.new( [ 
                    Mapper::Token.new( :literal, '(' ), 
                    Mapper::Token.new( :symbol, 'expr' ),
                    Mapper::Token.new( :literal, ' ' ),                   
                    Mapper::Token.new( :symbol, 'op' ),                  
                    Mapper::Token.new( :symbol, 'expr' ),                   
                    Mapper::Token.new( :literal, ')' ) 
                  ] )
                ] ),

       'op'  => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '+' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '*' ) ] )
                ] )
    }, 'expr' )

  end

  def test_depth_first
    m = Mapper::DepthFirst.new @grammar

    assert_equal( @grammar, m.grammar )

    assert_equal( '((x +y) *x)', m.phenotype( [2, 2, 0, 0, 1, 1, 0] ) )
    assert_equal( 7, m.used_length )
    assert_equal( '((x +y) *x)', m.phenotype( [5, 8, 3, 4, 1, 3, 6, 5, 3] ) )
    assert_equal( 7, m.used_length )

    assert_equal( '(y *(x +y))', m.phenotype( [2, 1, 1, 2, 0, 0, 1] ) )   
    assert_equal( 7, m.used_length )   
    assert_equal( '(y *(x +y))', m.phenotype( [2, 4, 3, 5, 0, 6, 1, 3, 5] ) )      
    assert_equal( 7, m.used_length )   
  end

  def test_breadth_first
    m = Mapper::BreadthFirst.new @grammar

    assert_equal( @grammar, m.grammar )

    assert_equal( '((x +y) *x)', m.phenotype( [2, 2, 1, 0, 0, 0, 1] ) )      
    assert_equal( 7, m.used_length )
    assert_equal( '((x +y) *x)', m.phenotype( [2, 5, 1, 3, 6, 2, 4, 5, 3] ) )
    assert_equal( 7, m.used_length )

    assert_equal( '(y *(x +y))', m.phenotype( [2, 1, 1, 2, 0, 0, 1] ) )   
    assert_equal( 7, m.used_length )   
    assert_equal( '(y *(x +y))', m.phenotype( [2, 4, 3, 5, 0, 6, 1, 3, 5] ) )      
    assert_equal( 7, m.used_length )   
  end

  def test_depth_locus
    m = Mapper::DepthLocus.new @grammar

    assert_equal( @grammar, m.grammar )

    assert_equal( '((x +y) *(y +x))', 
                 m.phenotype( [0,2,  2,2,  1,0,  0,1,  0,0,  0,2,  1,0,  0,0,  0,1,  0,1] ) )      
    assert_equal( 20, m.used_length )   

    assert_equal( '((x +y) *(y +x))', 
                 m.phenotype( [9,2,  5,5,  4,4,  2,7,  8,3,  0,8,  7,2,  6,0,  1,4,  3,1,  4,2,  1,3] ) )
    assert_equal( 20, m.used_length )
  end

  def test_breadth_locus
    m = Mapper::BreadthLocus.new @grammar

    assert_equal( @grammar, m.grammar )

    assert_equal( '((x +y) *(y +x))', 
                 m.phenotype( [0,2,  2,2,  1,1,  0,2,  0,0,  0,0,  1,1,  0,1,  0,0,  0,0] ) )      
    assert_equal( 20, m.used_length )   
    assert_equal( '((x +y) *(y +x))', 
                 m.phenotype( [4,5,  8,2,  3,3,  0,8,  6,6,  5,2,  1,4,  9,7,  2,4,  1,0,  4,2,  1,3] ) )
    assert_equal( 20, m.used_length )   
  end

  def test_depth_bucket
    m = Mapper::DepthBucket.new @grammar

    assert_equal( @grammar, m.grammar )

    assert_equal( '((x +y) *x)', m.phenotype( [4, 4, 0, 0, 2, 1, 0] ) )      
    assert_equal( 7, m.used_length )  

    assert_equal( '((x +y) *x)', m.phenotype( [5, 4, 1, 2, 3, 1, 1, 5, 3] ) )
    assert_equal( 7, m.used_length )  

    assert_equal( '((x +y) *x)', m.phenotype( [5, 4, 1, 4, 3, 3, 1, 4, 2] ) )   
    assert_equal( 7, m.used_length )  
   
  end

  def test_breath_bucket
    m = Mapper::BreadthBucket.new @grammar

    assert_equal( @grammar, m.grammar )

    assert_equal( '((x +y) *x)', m.phenotype( [4, 4, 1, 0, 0, 0, 2] ) )      
    assert_equal( 7, m.used_length )  
   
    assert_equal( '((x +y) *x)', m.phenotype( [5, 4, 3, 1, 0, 2, 3, 5, 3] ) )
    assert_equal( 7, m.used_length )  
   
    assert_equal( '((x +y) *x)', m.phenotype( [5, 4, 5, 1, 0, 0, 3, 4, 2] ) )   
    assert_equal( 7, m.used_length )  
   
  end

  def test_failing
    m = Mapper::BreadthFirst.new @grammar
    genotype1 = [2, 2, 0, 0]
    genotype2 = [2, 1, 0, 2, 0]

    assert_equal( 1, m.wraps_to_fail ) #default value

    assert_equal( nil, m.phenotype( genotype1 ) ) 
    assert_equal( genotype1.size * m.wraps_to_fail, m.used_length )
    assert_equal( nil, m.phenotype( genotype2 ) ) 
    assert_equal( genotype2.size * m.wraps_to_fail, m.used_length )

    m.wraps_to_fail = 2
    assert_equal( 2, m.wraps_to_fail )
    assert_equal( nil, m.phenotype( genotype1 ) ) 
    assert_equal( genotype1.size * m.wraps_to_fail, m.used_length )
    assert_equal( '(y +(x +y))', m.phenotype( genotype2 ) ) 
    assert_equal( 7, m.used_length )

    m2 = Mapper::BreadthFirst.new( @grammar, 20 )
    assert_equal( 20, m2.wraps_to_fail )
 
    m2 = Mapper::BreadthFirst.new( @grammar, wraps_to_fail=30 )
    assert_equal( 30, m2.wraps_to_fail )
  end
end

