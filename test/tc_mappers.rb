#!/usr/bin/ruby

require 'test/unit'
require 'lib/mapper'
require 'lib/validator'


class TC_Mappers < Test::Unit::TestCase

  def setup
    @grammar = Mapper::Grammar.new( { 
      'expr' => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'x' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'y' ) ] ),
                  Mapper::RuleAlt.new( [ 
                    Mapper::Token.new( :literal, '(' ), 
                    Mapper::Token.new( :symbol, 'expr', 42 ),
                    Mapper::Token.new( :literal, ' ' ),                   
                    Mapper::Token.new( :symbol, 'aop', 4 ),                  
                    Mapper::Token.new( :symbol, 'expr', 12 ),                   
                    Mapper::Token.new( :literal, ')' ) 
                  ] )
                ] ),

       'aop'  => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '+' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '*' ) ] )
                ] )
    }, 'expr' )

    Mapper::Validator.analyze_all @grammar
  end

  def test_depth_first
    m = Mapper::DepthFirst.new @grammar

    assert_equal( @grammar, m.grammar )

    assert_equal( '((x +y) *x)', m.phenotype( [2, 2, 0, 0, 1, 1, 0] ) )
    assert_equal( 7, m.used_length )
    assert_equal( 11, m.complexity )
   
    assert_equal( '((x +y) *x)', m.phenotype( [5, 8, 3, 4, 1, 3, 6, 5, 3] ) )
    assert_equal( 7, m.used_length )
    assert_equal( 11, m.complexity )

    assert_equal( '(y *(x +y))', m.phenotype( [2, 1, 1, 2, 0, 0, 1] ) )   
    assert_equal( 7, m.used_length )   
    assert_equal( 11, m.complexity )   

    assert_equal( '(y *(x +y))', m.phenotype( [2, 4, 3, 5, 0, 6, 1, 3, 5] ) )      
    assert_equal( 7, m.used_length )   
    assert_equal( 11, m.complexity )   
  end

  def test_breadth_first
    m = Mapper::BreadthFirst.new @grammar

    assert_equal( @grammar, m.grammar )

    assert_equal( '((x +y) *x)', m.phenotype( [2, 2, 1, 0, 0, 0, 1] ) )      
    assert_equal( 7, m.used_length )
    assert_equal( 11, m.complexity )     

    assert_equal( '((x +y) *x)', m.phenotype( [2, 5, 1, 3, 6, 2, 4, 5, 3] ) )
    assert_equal( 7, m.used_length )
    assert_equal( 11, m.complexity )     

    assert_equal( '(y *(x +y))', m.phenotype( [2, 1, 1, 2, 0, 0, 1] ) )   
    assert_equal( 7, m.used_length )   
    assert_equal( 11, m.complexity )  

    assert_equal( '(y *(x +y))', m.phenotype( [2, 4, 3, 5, 0, 6, 1, 3, 5] ) )      
    assert_equal( 7, m.used_length )   
    assert_equal( 11, m.complexity )     
  end

  def test_depth_locus
    m = Mapper::DepthLocus.new @grammar

    assert_equal( @grammar, m.grammar )

    assert_equal( '((x +y) *(y +x))', 
                 m.phenotype( [0,2,  2,2,  1,0,  0,1,  0,0,  0,2,  1,0,  0,0,  0,1,  0,1] ) )      
    assert_equal( 20, m.used_length )   
    assert_equal( 17, m.complexity )     

    assert_equal( '((x +y) *(y +x))', 
                 m.phenotype( [9,2,  5,5,  4,4,  2,7,  8,3,  0,8,  7,2,  6,0,  1,4,  3,1,  4,2,  1,3] ) )
    assert_equal( 20, m.used_length )
    assert_equal( 17, m.complexity )        
  end

  def test_breadth_locus
    m = Mapper::BreadthLocus.new @grammar

    assert_equal( @grammar, m.grammar )

    assert_equal( '((x +y) *(y +x))', 
                 m.phenotype( [0,2,  2,2,  1,1,  0,2,  0,0,  0,0,  1,1,  0,1,  0,0,  0,0] ) )      
    assert_equal( 20, m.used_length )   
    assert_equal( 17, m.complexity )        
    assert_equal( '((x +y) *(y +x))', 
                 m.phenotype( [4,5,  8,2,  3,3,  0,8,  6,6,  5,2,  1,4,  9,7,  2,4,  1,0,  4,2,  1,3] ) )
    assert_equal( 20, m.used_length )   
    assert_equal( 17, m.complexity )        
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
    assert( genotype1.size * m.wraps_to_fail < m.used_length )
    assert_equal( nil, m.phenotype( genotype2 ) ) 
    assert( genotype2.size * m.wraps_to_fail < m.used_length )

    m.wraps_to_fail = 2
    assert_equal( 2, m.wraps_to_fail )
    assert_equal( nil, m.phenotype( genotype1 ) ) 
    assert( genotype1.size * m.wraps_to_fail < m.used_length )
    assert_equal( '(y +(x +y))', m.phenotype( genotype2 ) ) 
    assert_equal( 7, m.used_length )

    m2 = Mapper::BreadthFirst.new( @grammar, 20 )
    assert_equal( 20, m2.wraps_to_fail )
  end

  def test_failing_locus
    m = Mapper::BreadthLocus.new @grammar
    genotype1 = [0,2,  0,2,   0,0,   0,0]
    genotype2 = [0,2,  0,1,   0,0,   0,2,   0,0]

    assert_equal( 1, m.wraps_to_fail ) #default value

    assert_equal( nil, m.phenotype( genotype1 ) ) 
    assert( genotype1.size * m.wraps_to_fail < m.used_length )
    assert_equal( nil, m.phenotype( genotype2 ) ) 
    assert( genotype2.size * m.wraps_to_fail < m.used_length )

    m.wraps_to_fail = 2
    assert_equal( 2, m.wraps_to_fail )
    assert_equal( nil, m.phenotype( genotype1 ) ) 
    assert( genotype1.size * m.wraps_to_fail < m.used_length )
    assert_equal( '(y +(x +y))', m.phenotype( genotype2 ) ) 
    assert_equal( 7*2, m.used_length )
  end

  def test_fading_trivial
    m = Mapper::BreadthFirst.new @grammar
    genotype1 = [2, 2, 0, 0]

    assert_equal( 1, m.wraps_to_fail ) #default value
    assert_equal( nil, m.wraps_to_fading ) #default value

    assert_equal( nil, m.phenotype( genotype1 ) ) 
    assert( genotype1.size * m.wraps_to_fail < m.used_length )

    m.wraps_to_fail = 3
    m.wraps_to_fading = 2
    assert_equal( 2, m.wraps_to_fading )
    assert_equal( '(((x +x) +x) +x)', m.phenotype( genotype1 ) ) 
    assert_equal( 10, m.used_length )

    m2 = Mapper::BreadthFirst.new( @grammar, 10, 20 )
    assert_equal( 20, m2.wraps_to_fading )
  end

  def test_fading_non_trivial
    grammar = Mapper::Validator.analyze_all( Mapper::Grammar.new( { 
      'expr' => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ 
                    Mapper::Token.new( :literal, '(' ), 
                    Mapper::Token.new( :symbol, 'expr', 42 ),
                    Mapper::Token.new( :literal, ' ' ),                   
                    Mapper::Token.new( :symbol, 'op', 4 ),                  
                    Mapper::Token.new( :symbol, 'expr', 12 ),                   
                    Mapper::Token.new( :literal, ')' ) 
                  ] ), # :cyclic rule has the index 0 (nontrivial)

                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'x' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'y' ) ] ),
                   
                ] ),

       'op'  => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '+' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '*' ) ] )
                ] )
    }, 'expr' ))

    m = Mapper::BreadthFirst.new grammar

    assert_equal( :cyclic, m.grammar['expr'].recursivity )
    assert_equal( :cyclic, m.grammar['expr'][0].recursivity )   
    assert_equal( :terminating, m.grammar['expr'][1].recursivity )      
    assert_equal( :terminating, m.grammar['expr'][2].recursivity )         
    assert_equal( :terminating, m.grammar['op'].recursivity )
    assert_equal( :terminating, m.grammar['op'][0].recursivity )   
    assert_equal( :terminating, m.grammar['op'][1].recursivity )      
 
    genotype1 = [0, 0, 1, 1]

    assert_equal( 1, m.wraps_to_fail ) #default value
    assert_equal( nil, m.wraps_to_fading ) #default value

    assert_equal( nil, m.phenotype( genotype1 ) ) 
    assert( genotype1.size * m.wraps_to_fail < m.used_length )

    m.wraps_to_fail = 3
    m.wraps_to_fading = 2
    assert_equal( 2, m.wraps_to_fading )
    assert_equal( '(((x +x) +x) *x)', m.phenotype( genotype1 ) ) 
    assert_equal( 10, m.used_length )
  end
 
  def test_locus_eating
    grammar = Mapper::Validator.analyze_all( Mapper::Grammar.new( { 
      'expr' => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'x' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'y' ) ] ),
                  Mapper::RuleAlt.new( [ 
                    Mapper::Token.new( :literal, '(' ), 
                    Mapper::Token.new( :symbol, 'expr', 42 ),
                    Mapper::Token.new( :literal, ' ' ),                   
                    Mapper::Token.new( :symbol, 'op', 4 ),                  
                    Mapper::Token.new( :symbol, 'expr', 12 ),                   
                    Mapper::Token.new( :literal, ')' ) 
                  ] )
                ] ),

       'op'  => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '+' ) ] ), #trivial rule
                ] )
    }, 'expr' ))
 
    m = Mapper::DepthLocus.new grammar
    m.consume_trivial_codons = false
    assert_equal( false, m.consume_trivial_codons )

    assert_equal( '((x +y) +(y +x))', 
                             #[0,2,  2,2,  1,0,  0,1,  0,0,  0,2,  1,0,  0,0,  0,1,  0,1]        
                 m.phenotype( [  2,  2,2,  1,    0,1,    0,  0,2,  1,    0,0,    1,     ] ) )      
    assert_equal( 13, m.used_length )   

    assert_equal( '((x +y) +(y +x))', 
                             #[9,2,  5,5,  4,4,  2,7,  8,3,  0,8,  7,2,  6,0,  1,4,  3,1,  4,2,  1,3]       
                 m.phenotype( [  2,  5,5,  4,    2,7,    3,  0,8,  7,    6,0,    4,        4,2,  1,3] ) )
    assert_equal( 13, m.used_length )

    m2 = Mapper::BreadthFirst.new( @grammar, 10, 20 )
    assert_equal( true, m2.consume_trivial_codons ) #default
    m2 = Mapper::BreadthFirst.new( @grammar, 10, 20, false )
    assert_equal( false, m2.consume_trivial_codons ) 
  end
 
  def test_empty
    m = Mapper::BreadthFirst.new @grammar
    genotype1 = []
    assert_equal( nil, m.phenotype( genotype1 ) ) 
  end

  def test_mapper_track
    m = Mapper::DepthFirst.new @grammar
    
    assert_equal( false, m.track_support_on )
    assert_equal( '((x +y) *x)', m.phenotype( [2, 2, 0, 0, 1, 1, 0] ) )
    assert_equal( nil, m.track_support )
    
    m.track_support_on = true
    assert_equal( true, m.track_support_on )
    assert_equal( '((x +y) *x)', m.phenotype( [2, 2, 0, 0, 1, 1, 0] ) )
    
    track = [
      Mapper::TrackNode.new( 'expr', 0, 6 ),
      Mapper::TrackNode.new( 'expr', 1, 4, 0 ),
      Mapper::TrackNode.new( 'expr', 2, 2, 1 ),
      Mapper::TrackNode.new( 'aop', 3, 3, 1 ),
      Mapper::TrackNode.new( 'expr', 4, 4, 1 ),
      Mapper::TrackNode.new( 'aop', 5, 5, 0 ),
      Mapper::TrackNode.new( 'expr', 6, 6, 0 )
    ]
    assert_equal( track, m.track_support )
    
    m.track_support_on = false
    assert_equal( false, m.track_support_on )
    assert_equal( '((x +y) *x)', m.phenotype( [2, 2, 0, 0, 1, 1, 0] ) )
    assert_equal( nil, m.track_support )
  
  end
  
  def test_mapper_track2
    m = Mapper::DepthFirst.new @grammar
    m.track_support_on = true
    assert_equal( '(y *(x +y))', m.phenotype( [2, 4, 3, 5, 0, 6, 1, 3, 5] ) )  

    track = [
      Mapper::TrackNode.new( 'expr', 0, 6 ),
      Mapper::TrackNode.new( 'expr', 1, 1, 0 ),
      Mapper::TrackNode.new( 'aop', 2, 2, 0 ),
      Mapper::TrackNode.new( 'expr', 3, 6, 0 ),
      Mapper::TrackNode.new( 'expr', 4, 4, 3 ),     
      Mapper::TrackNode.new( 'aop', 5, 5, 3 ),     
      Mapper::TrackNode.new( 'expr', 6, 6, 3 ),          
    ]
    assert_equal( track, m.track_support )
  end

  def test_depth_locus_track_bugfix
    m = Mapper::DepthLocus.new @grammar
    m.track_support_on = true

    assert_equal( '((x +y) *(y +x))', 
                 m.phenotype( [0,2,  2,2,  1,0,  0,1,  0,0,  0,2,  1,0,  0,0,  0,1,  0,1] ) )   
    # e = x / y / e o e
    # o = + / *

    track = [
      Mapper::TrackNode.new( 'expr', 0, 19, nil ), # 0:[ ,2]      <e>      <o>      <e>
      Mapper::TrackNode.new( 'expr', 2,  9, 0 ),   # 1:[2,2]      <e>      <o> (<e> <o> <e>)   
      Mapper::TrackNode.new( 'aop',  4,  5, 1 ),   # 2:[1,0]      <e>      <o> (<e>  +  <e>)   
      Mapper::TrackNode.new( 'expr', 6,  7, 1 ),   # 3:[0,1]      <e>      <o> ( y   +  <e>)    
      Mapper::TrackNode.new( 'expr', 8,  9, 1 ),   # 4:[ ,0]      <e>      <o> ( y   +   x ) 
      Mapper::TrackNode.new( 'expr',10, 17, 0 ),   # 5:[0,2] (<e> <o> <e>) <o> ( y   +   x ) 
      Mapper::TrackNode.new( 'aop', 12, 13, 5 ),   # 6:[1,0] (<e>  +  <e>) <o> ( y   +   x )      
      Mapper::TrackNode.new( 'expr',14, 15, 5 ),   # 7:[0,0] ( x   +  <e>) <o> ( y   +   x )           
      Mapper::TrackNode.new( 'expr',16, 17, 5 ),   # 8:[ ,1] ( x   +   y ) <o> ( y   +   x )          
      Mapper::TrackNode.new( 'aop', 18, 19, 0 ),   # 9:[ ,1] ( x   +   y )  *  ( y   +   x )               
    ]
    assert_equal( track, m.track_support )
   
  end

end


