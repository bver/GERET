
$LOAD_PATH << '.' unless $LOAD_PATH.include? '.'

require 'test/unit'
require 'lib/mapper'
require 'lib/validator'
require 'lib/mutation_simplify'

include Operator

class TC_MutationSimplify < Test::Unit::TestCase
  
  def setup

# grammar:    
# expr = "x" / "y" / digit "." digit / fn1arg "(" expr ")" / expr / "(" expr op expr ")"
# op = "+" / "-" / "/" / "*"
# fn1arg = "ABS" / "SIN" / "COS" / "EXP" / "LOG"
# digit = "0" / "1" / "2" / "3" / "4" / "5" / "6" / "7" / "8" / "9"

    @grammar = Mapper::Grammar.new( { 
      'expr' => Mapper::Rule.new( [
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'x' ) ] ),        # 0
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'y' ) ] ),        # 1
                  Mapper::RuleAlt.new( [                                                # 2
                    Mapper::Token.new( :symbol, 'digit' ),      
                    Mapper::Token.new( :literal, '.' ),                   
                    Mapper::Token.new( :symbol, 'digit' ) 
                  ] ),                   
                  Mapper::RuleAlt.new( [                                                # 3
                    Mapper::Token.new( :symbol, 'fn1arg' ),      
                    Mapper::Token.new( :literal, '(' ),                   
                    Mapper::Token.new( :symbol, 'expr' ),
                    Mapper::Token.new( :literal, ')' )                     
                  ] ),                   
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :symbol, 'expr' ) ] ),      # 4          
                  Mapper::RuleAlt.new( [                                                # 5
                    Mapper::Token.new( :literal, '(' ),                   
                    Mapper::Token.new( :symbol, 'expr' ),
                    Mapper::Token.new( :symbol, 'op' ),
                    Mapper::Token.new( :symbol, 'expr' ),
                    Mapper::Token.new( :literal, ')' )                     
                  ] )
                ] ),

      'op'  => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '+' ) ] ), # 0
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '-' ) ] ), # 1
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '/' ) ] ), # 2
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '*' ) ] )  # 3
                ] ),

      'fn1arg'  => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'ABS' ) ] ), # 0
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'SIN' ) ] ), # 1
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'COS' ) ] ), # 2
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'EXP' ) ] ), # 3
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'LOG' ) ] )  # 4               
                ] ),
 
      'digit' => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '0' ) ] ),        # 0
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '1' ) ] ),        # 1                 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '2' ) ] ),        # 2                 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '3' ) ] ),        # 3
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '4' ) ] ),        # 4                 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '5' ) ] ),        # 5                 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '6' ) ] ),        # 6
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '7' ) ] ),        # 7                 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '8' ) ] ),        # 8                
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '8' ) ] )         # 9
                ] )
    }, 'expr' )

    Mapper::Validator.analyze_all @grammar

    match1 = [ # '(0.0*omit)' -->
      # :symbol, :alt_idx, :dir, :parent_arg 
      MutationSimplify::Pattern.new( 'expr',  5,-1, 0 ),   # 0. expr = "(" expr:zero op expr:omit ")"
      MutationSimplify::Pattern.new( 'expr',  2,-1, 0 ),   # 1. expr:zero = _digit:Ai "." _digit:Af
      MutationSimplify::Pattern.new( 'digit', 0, 0, 0 ),   # 2. digit:Ai = "0"
      MutationSimplify::Pattern.new( 'digit', 0, 1, 1 ),   # 3. digit:Af = "0"
      MutationSimplify::Pattern.new( 'op',    3, 0, 1 ),   # 4. op:er = "*"
      MutationSimplify::Subtree.new( 'omit',     1, 2 )    # 5. * expr:omit    
    ]
    outcome1 = [ # --> '0.0'
      1  # expr:zero
    ]

    match2 = [ # 'EXP(LOG(inner))' -->
      # :symbol, :alt_idx, :dir, :parent_arg     
      MutationSimplify::Pattern.new( 'expr',    3,-1, 0 ),   # 0. expr = fn1arg:exp "(" expr:log ")" 
      MutationSimplify::Pattern.new( 'fn1arg',  3, 0, 0 ),   # 1. fn1arg:exp = "EXP"
      MutationSimplify::Pattern.new( 'expr',    3,-1, 1 ),   # 2. expr:log = fn1arg:log "(" expr:inner ")" 
      MutationSimplify::Pattern.new( 'fn1arg',  4, 0, 0 ),   # 3. fn1arg:log = "LOG"
      MutationSimplify::Subtree.new( 'inner',      2, 1 )    # 4. * expr:inner     
    ]
    outcome2 = [ # --> 'inner'
      4  # wildcard expr:inner
    ]

    match3 = [ # '(inner*1.0)' -->
      # :symbol, :alt_idx, :dir, :parent_arg     
      MutationSimplify::Pattern.new( 'expr',  5,  -1, 0 ),   # 0. expr = "(" expr:inner op expr:one ")" 
      MutationSimplify::Subtree.new( 'inner',      0, 0 ),   # 1. * inner     
      MutationSimplify::Pattern.new( 'op',    3,   0, 1 ),   # 2. op:er = "*"
      MutationSimplify::Pattern.new( 'expr',  2,  -1, 2 ),   # 3. expr:zero = _digit:Ai "." _digit:Af     
      MutationSimplify::Pattern.new( 'digit', 1,   0, 0 ),   # 2. digit:Ai = "1"
      MutationSimplify::Pattern.new( 'digit', 0,   2, 1 )    # 3. digit:Af = "0"
    ]
    outcome3 = [ # --> 'inner'
      1 # wildcard expr:inner     
    ]

    @rules = [ [match1,outcome1], [match2,outcome2], [match3,outcome3] ]
  end

  def test_match_patterns
    track_reloc = [
      Mapper::TrackNode.new( 'expr',  0, 8, nil, 5, 0 ),
      Mapper::TrackNode.new( 'expr',  1, 6, 0,   5, 0 ),     
      Mapper::TrackNode.new( 'expr',  2, 4, 1,   2, 0 ),    
      Mapper::TrackNode.new( 'digit', 3, 3, 2,   0, 0 ),         
      Mapper::TrackNode.new( 'digit', 4, 4, 2,   0, 1 ), #4
      Mapper::TrackNode.new( 'op',    5, 5, 1,   3, 1 ),     
      Mapper::TrackNode.new( 'expr',  6, 6, 1,   1, 2 ),     
      Mapper::TrackNode.new( 'op',    7, 7, 0,   2, 1 ),     
      Mapper::TrackNode.new( 'expr',  8, 8, 0,   0, 2 )
    ]   

    s = MutationSimplify.new 
    ptm = s.match_patterns( track_reloc, @rules.first.first, 1 )
    ptm_expected = [ 1, 2, 3, 4, 5, [6] ]

    assert_equal( ptm_expected, ptm ) # matches

    ptm = s.match_patterns( track_reloc, @rules.first.first, 0 )
    assert_equal( [], ptm ) # no match  
  
  end

  def test_reloc_match_depth_first
    # [5, 5, 2, 0, 0, 3, 1, 2, 0] -> ((0.0*y)/x)
    # :symbol, :from, :to, :back, :alt_idx, :loc_idx  
    track = [
      Mapper::TrackNode.new( 'expr',  0, 8, nil, 5, 0 ),
      Mapper::TrackNode.new( 'expr',  1, 6, 0,   5, 0 ),     
      Mapper::TrackNode.new( 'expr',  2, 4, 1,   2, 0 ),    
      Mapper::TrackNode.new( 'digit', 3, 3, 2,   0, 0 ),         
      Mapper::TrackNode.new( 'digit', 4, 4, 2,   0, 0 ), #4
      Mapper::TrackNode.new( 'op',    5, 5, 1,   3, 0 ),     
      Mapper::TrackNode.new( 'expr',  6, 6, 1,   1, 0 ),     
      Mapper::TrackNode.new( 'op',    7, 7, 0,   2, 0 ),     
      Mapper::TrackNode.new( 'expr',  8, 8, 0,   0, 0 )
    ]
   
    track_reloc = [
      Mapper::TrackNode.new( 'expr',  0, 8, nil, 5, 0 ),
      Mapper::TrackNode.new( 'expr',  1, 6, 0,   5, 0 ),     
      Mapper::TrackNode.new( 'expr',  2, 4, 1,   2, 0 ),    
      Mapper::TrackNode.new( 'digit', 3, 3, 2,   0, 0 ),         
      Mapper::TrackNode.new( 'digit', 4, 4, 2,   0, 1 ), #4
      Mapper::TrackNode.new( 'op',    5, 5, 1,   3, 1 ),     
      Mapper::TrackNode.new( 'expr',  6, 6, 1,   1, 2 ),     
      Mapper::TrackNode.new( 'op',    7, 7, 0,   2, 1 ),     
      Mapper::TrackNode.new( 'expr',  8, 8, 0,   0, 2 )
    ]   

    s = MutationSimplify.new 
    s.mapper_type = 'DepthFirst'
    assert_equal( track_reloc, s.reloc(track) )

    assert_equal( 9, track.size )
    ptm = s.match( track_reloc, @rules.first.first ) 
    assert_equal( 9, track.size )

    ptm_expected = [ 1, 2, 3, 4, 5, [6] ]
    assert_equal( ptm_expected, ptm ) # matches

    track_reloc[4].alt_idx = 4 # disable matching
    assert_equal( [], s.match( track_reloc, @rules.first.first ) )
  end

  def test_replacement
    genome = [5, 5, 2, 0, 0, 3, 1, 2, 0]

    ptm = [ 1, 2, 3, 4, 5, [6,4,5,6,7] ]

    track_reloc = [
      Mapper::TrackNode.new( 'expr',  0, 8, nil, 5, 0 ),
      Mapper::TrackNode.new( 'expr',  1, 6, 0,   5, 0 ),     
      Mapper::TrackNode.new( 'expr',  2, 4, 1,   2, 0 ),    
      Mapper::TrackNode.new( 'digit', 3, 3, 2,   0, 0 ),         
      Mapper::TrackNode.new( 'digit', 4, 4, 2,   0, 1 ), #4
      Mapper::TrackNode.new( 'op',    5, 5, 1,   3, 1 ),     
      Mapper::TrackNode.new( 'expr',  6, 6, 1,   1, 2 ),     
      Mapper::TrackNode.new( 'op',    7, 7, 0,   2, 1 ),     
      Mapper::TrackNode.new( 'expr',  8, 8, 0,   0, 2 )
    ]   
   
    s = MutationSimplify.new

    outcome = [ 
      3, # digit:Af -> genome[4..4] -> 0
      1  # expr:zero -> genome[2..4] -> 2,0,0
    ]    
    expected = [ 5,    0, 2,0,0,    2, 0 ]
    replaced = s.replace( genome, ptm, @rules.first.first, outcome, track_reloc )
    assert_equal(expected, replaced)

    outcome = [
      5, # omit.first ->  genome[6..6] -> 1
      2  # digit:Ai -> genome[3..3] -> 0
    ]    
    expected = [ 5,    1, 0,    2, 0 ]
    replaced = s.replace( genome, ptm, @rules.first.first, outcome, track_reloc )
    assert_equal(expected, replaced)

  end

  def test_depth_first_mult_by_zero
    m = Mapper::DepthFirst.new @grammar
    m.track_support_on = true
   
    genotype_src1 = [5, 0, 1, 5, 2, 0, 0, 3, 1]
    assert_equal( '(x-(0.0*y))', m.phenotype( genotype_src1 ) )
    track_src1 = m.track_support   

    genotype_src2 = [5, 0, 1, 5, 2, 0, 4, 3, 1]
    assert_equal( '(x-(0.4*y))', m.phenotype( genotype_src2 ) )
    track_src2 = m.track_support      

    genotype_src3 = [5, 0, 1, 5, 2, 0, 0, 3, 3, 1, 2, 4, 2]
    assert_equal( '(x-(0.0*SIN(4.2)))', m.phenotype( genotype_src3 ) )
    track_src3 = m.track_support   

    genotype_src4 = [5, 5, 2, 0, 0, 3, 1, 2, 0]
    assert_equal( '((0.0*y)/x)', m.phenotype( genotype_src4 ) )
    track_src4 = m.track_support   
   
    s = MutationSimplify.new
    s.rules = @rules
    s.mapper_type = 'DepthFirst'      
    assert_equal( @rules, s.rules )

    genotype_dest = [5, 0, 1, 2, 0, 0]
    assert_equal( '(x-0.0)', m.phenotype( genotype_dest ) )   
   
    mutant = s.mutation( genotype_src1, track_src1 )
    assert_equal( genotype_dest, mutant ) # simplified

    mutant = s.mutation( genotype_src2, track_src2 )
    assert_equal( genotype_src2, mutant ) # no match, no change

    mutant = s.mutation( genotype_src3, track_src3 )
    assert_equal( genotype_dest, mutant ) # simplified

    genotype_dest4 = [5, 2, 0, 0, 2, 0]
    assert_equal( '(0.0/x)', m.phenotype( genotype_dest4 ) )   

    mutant = s.mutation( genotype_src4, track_src4 )
    assert_equal( genotype_dest4, mutant ) # simplified
   
  end

  def test_depth_first_log_exp
    m = Mapper::DepthFirst.new @grammar
    m.track_support_on = true
 
    genotype = [3, 3, 3, 4, 0]
    assert_equal( 'EXP(LOG(x))', m.phenotype( genotype ) ) 
    track = m.track_support 

    s = MutationSimplify.new
    s.rules = @rules
    s.mapper_type = 'DepthFirst'      
  
    expected = [0]   
    assert_equal( 'x', m.phenotype( expected ) ) 

    mutant = s.mutation( genotype, track )
    assert_equal( expected, mutant ) # simplified
  end

  def test_mapper_type_wrong
    s = MutationSimplify.new
    assert_nil( s.mapper_type )

    exception = assert_raise( RuntimeError ) { s.reloc [] }
    assert_equal( "MutationSimplify: mapper_type not selected", exception.message )
   
    s.mapper_type = 'undefined'
    exception = assert_raise( RuntimeError ) { s.reloc [] }
    assert_equal( "MutationSimplify: mapper_type not supported", exception.message )
  end

  def test_reloc_depth_locus
    # [0,5,  1,2,  1,0,  0,5,  2,1,  0,2,  0,0,  0,0,  0,3 ] => '((0.0*y)/x)'
    # :symbol, :from, :to, :back, :alt_idx, :loc_idx  
    track = [
      Mapper::TrackNode.new( 'expr',  0,  17, nil, 5, 0 ), # 0. expr = <expr> <op> <expr> ")"
      Mapper::TrackNode.new( 'op',    2,  3,  0,   2, 1 ), # 1. op = "/"
      Mapper::TrackNode.new( 'expr',  4,  5,  0,   0, 1 ), # 2. expr = "x"
      Mapper::TrackNode.new( 'expr',  6,  17, 0,   5, 0 ), # 3. expr = "(" <expr> <op> <expr> ")"
      Mapper::TrackNode.new( 'expr',  8,  9,  3,   1, 2 ), # 4. expr = "y"
      Mapper::TrackNode.new( 'expr',  10, 15, 3,   2, 0 ), # 5. expr = '<digit> "." <digit>'
      Mapper::TrackNode.new( 'digit', 12, 13, 5,   0, 0 ), # 6. digit = "0"
      Mapper::TrackNode.new( 'digit', 14, 15, 5,   0, 0 ), # 7. digit = "0"
      Mapper::TrackNode.new( 'op',    16, 17, 3,   3, 0 )  # 8. op = "*"
    ]

    track_reloc = [
      Mapper::TrackNode.new( 'expr',  0,  17, nil, 5, 0 ), # 0. expr = <expr> <op> <expr> ")"
      Mapper::TrackNode.new( 'op',    2,  3,  0,   2, 1 ), # 1. op = "/"
      Mapper::TrackNode.new( 'expr',  4,  5,  0,   0, 2 ), # 2. expr = "x"
      Mapper::TrackNode.new( 'expr',  6,  17, 0,   5, 0 ), # 3. expr = "(" <expr> <op> <expr> ")"
      Mapper::TrackNode.new( 'expr',  8,  9,  3,   1, 2 ), # 4. expr = "y"
      Mapper::TrackNode.new( 'expr',  10, 15, 3,   2, 0 ), # 5. expr = '<digit> "." <digit>'
      Mapper::TrackNode.new( 'digit', 12, 13, 5,   0, 0 ), # 6. digit = "0"
      Mapper::TrackNode.new( 'digit', 14, 15, 5,   0, 1 ), # 7. digit = "0"
      Mapper::TrackNode.new( 'op',    16, 17, 3,   3, 1 )  # 8. op = "*"
    ]

    s = MutationSimplify.new
    s.mapper_type = 'DepthLocus'

    assert_equal( track_reloc, s.reloc(track) )

    expected_ptm = [3, 5, 6, 7, 8, [4]]

    ptm = s.match( track_reloc, @rules.first.first )   
    assert_equal( expected_ptm, ptm )

    track_reloc[7].alt_idx = 1 # disable matching by 0.0 -> 0.1
    assert_equal( [], s.match( track_reloc, @rules.first.first ) )
  end

  def test_depth_locus
     m = Mapper::DepthLocus.new @grammar
     m.track_support_on = true
   
     genotype_src1 =  [0,5,  1,2,  1,0,  0,5,  2,1,  0,2,  0,0,  0,0,  0,3 ]
     assert_equal( '((0.0*y)/x)', m.phenotype( genotype_src1 ) )
     track_src1 = m.track_support

     genotype_dest1 = [0,5,  1,2,  1,0,             0,2,  0,0,  0,0        ]
     assert_equal( '(0.0/x)', m.phenotype( genotype_dest1 ) )

     s = MutationSimplify.new
     s.mapper_type = 'DepthLocus'
     s.rules = @rules

     mutant = s.mutation( genotype_src1, track_src1 )
     assert_equal( genotype_dest1, mutant ) # simplified
  end

  def test_subtree_depth_locus
    m = Mapper::DepthLocus.new @grammar
    m.track_support_on = true
    
    genotype_src1 = [0,5, 1,3, 0,3, 1,1, 0,1, 0,2, 1,0, 0,1]
    assert_equal( '(SIN(y)*1.0)', m.phenotype( genotype_src1 ) )
    track_src1 = m.track_support

    genotype_dest1 = [0,3, 1,1, 0,1]
    assert_equal( 'SIN(y)', m.phenotype( genotype_dest1 ) )

    s = MutationSimplify.new
    s.mapper_type = 'DepthLocus'
    s.rules = @rules

    mutant = s.mutation( genotype_src1, track_src1 )
    assert_equal( genotype_dest1, mutant ) # simplified
  end

  def test_subtree_depth_first
    m = Mapper::DepthFirst.new @grammar
    m.track_support_on = true

    genotype_src1 = [3,4,5,3,1,1,3,2,1,0] 
    assert_equal( 'LOG((SIN(y)*1.0))', m.phenotype( genotype_src1 ) )
    track_src1 = m.track_support

    genotype_dest1 = [3,4,3,1,1] 
    assert_equal( 'LOG(SIN(y))', m.phenotype( genotype_dest1 ) )

    s = MutationSimplify.new
    s.mapper_type = 'DepthFirst'
    s.rules = @rules

    mutant = s.mutation( genotype_src1, track_src1 )
    assert_equal( genotype_dest1, mutant ) # simplified
  end

end

