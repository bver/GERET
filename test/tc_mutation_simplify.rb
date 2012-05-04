
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

    match1 = [
      # :symbol, :alt_idx, :parent_idx, :parent_arg 
      MutationSimplify::Pattern.new( 'expr',  5, nil, 0 ), # 0. expr = "(" expr:zero op:er expr:inner ")"
      MutationSimplify::Pattern.new( 'expr',  2, 0, 0 ),   # 1. expr:zero(0) = _digit:Ai "." _digit:Af
      MutationSimplify::Pattern.new( 'op',    3, 0, 1 ),   # 2. op:er(1) = "*"
      MutationSimplify::Pattern.new( 'digit', 0, 1, 0 ),   # 3. digit:Ai(0) = "0"
      MutationSimplify::Pattern.new( 'digit', 0, 1, 1 )    # 4. digit:Ai(1) = "0"    
    ]
    outcome1 = [ 
      MutationSimplify::Replacement.new( 0, 0 ) # expr:zero(0) : parent=0, loc=0
    ]  # 0. expr:zero(0)

    match2 = [
      # :symbol, :alt_idx, :parent_idx, :parent_arg     
      MutationSimplify::Pattern.new( 'expr',    3, nil, 0 ), # 0. expr = fn1arg:exp "(" expr:log ")" 
      MutationSimplify::Pattern.new( 'fn1arg',  3, 0, 0 ),   # 1. fn1arg:exp = "EXP"
      MutationSimplify::Pattern.new( 'expr',    3, 0, 1 ),   # 2. expr:log = fn1arg:log "(" expr:inner ")" 
      MutationSimplify::Pattern.new( 'fn1arg',  4, 2, 0 )    # 3. fn1arg:log = "LOG"
    ]
    outcome2 = [
      MutationSimplify::Replacement.new( 2, 1 ) # expr:inner(1) : parent=1 loc=0    
    ]


    @rules = [ [match1,outcome1], [match2,outcome2] ]
  end

  def test_match
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
    assert_equal( track_reloc, s.reloc(track) )

    assert_equal( 9, track.size )
    current = s.match( track, @rules.first.first ) 
    assert_equal( 9, track.size )

    current_expected = [
      Mapper::TrackNode.new( 'expr',  1, 6, nil, 5, 0 ),     
      Mapper::TrackNode.new( 'expr',  2, 4, 0,   2, 0 ),    
      Mapper::TrackNode.new( 'digit', 3, 3, 1,   0, 0 ),         
      Mapper::TrackNode.new( 'digit', 4, 4, 1,   0, 1 ), 
      Mapper::TrackNode.new( 'op',    5, 5, 0,   3, 1 ),     
      Mapper::TrackNode.new( 'expr',  6, 6, 0,   1, 2 )     
    ]
    
    assert_equal( current_expected.size, current.size )   
    assert_equal( current_expected, current )

    track[4].alt_idx = 4
    assert_equal( [], s.match( track, @rules.first.first ) )
  end

  def test_replacement
    genome = [5, 5, 2, 0, 0, 3, 1, 2, 0]

    current = [
      Mapper::TrackNode.new( 'expr',  1, 6, nil, 5, 0 ),     
      Mapper::TrackNode.new( 'expr',  2, 4, 0,   2, 0 ),    
      Mapper::TrackNode.new( 'digit', 3, 3, 1,   0, 0 ),         
      Mapper::TrackNode.new( 'digit', 4, 4, 1,   0, 1 ), 
      Mapper::TrackNode.new( 'op',    5, 5, 0,   3, 1 ),     
      Mapper::TrackNode.new( 'expr',  6, 6, 0,   1, 2 )     
    ]
    
    outcome = [ 
      MutationSimplify::Replacement.new( 1, 1 ), # genome[4..4]
      MutationSimplify::Replacement.new( 0, 2 )  # genome[6..6]
    ]    

    expected = [ 5,   0,1,   2, 0 ]
    s = MutationSimplify.new
    replaced = s.replace( genome, current, @rules.first.first, outcome )
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
  
    expected = [0]   
    assert_equal( 'x', m.phenotype( expected ) ) 

    mutant = s.mutation( genotype, track )
    assert_equal( expected, mutant ) # simplified
  end
end

