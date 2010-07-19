#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/mutation_altering'

include Operator

class TC_MutationAltering < Test::Unit::TestCase
  
  def setup
    @parent1 = [2, 2, 0, 0, 1, 1, 0]

    @track1 = [
      Mapper::TrackNode.new( 'expr', 0, 6 ),
      Mapper::TrackNode.new( 'expr', 1, 4 ), #1st
      Mapper::TrackNode.new( 'expr', 2, 2 ),
      Mapper::TrackNode.new( 'aop', 3, 3 ),  #2nd 
      Mapper::TrackNode.new( 'expr', 4, 4 ),
      Mapper::TrackNode.new( 'aop', 5, 5 ),
      Mapper::TrackNode.new( 'expr', 6, 6 )
    ]
    @grammar1 = Grammar.new( { 
      'expr' => Rule.new( [ 
                  RuleAlt.new( [ Token.new( :symbol, 'aop' ) ] )
                ], :cyclic, :nodal ),

       'aop'  => Rule.new( [ 
                  RuleAlt.new( [ Token.new( :symbol, 'expr', 42 ) ] )
                ], :infinite, :structural )
    }, 'expr' )
  end

  def test_bit_basics
    m = MutationBitNodal.new @grammar1
 
    m.random = MockRand.new [{5=>3}, {8=>0}]
    mutant = m.mutation( @parent1, @track1 )

    assert_equal( [2, 2, 0, 0, 0, 1, 0], mutant )
    assert_equal( [2, 2, 0, 0, 1, 1, 0], @parent1 ) 
   
    m.random = MockRand.new [{5=>1}, {8=>2}]
    mutant = m.mutation( @parent1, @track1 )  

    assert_equal( [2, 6, 0, 0, 1, 1, 0], mutant )
    assert_equal( [2, 2, 0, 0, 1, 1, 0], @parent1 ) 


    m = MutationBitStructural.new @grammar1
 
    m.random = MockRand.new [{2=>1}, {8=>1}]
    mutant = m.mutation( @parent1, @track1 )

    assert_equal( [2, 2, 0, 0, 1, 3, 0], mutant )
    assert_equal( [2, 2, 0, 0, 1, 1, 0], @parent1 ) 
   
    m.random = MockRand.new [{2=>0}, {8=>0}]
    mutant = m.mutation( @parent1, @track1 )  

    assert_equal( [2, 2, 0, 1, 1, 1, 0], mutant )
    assert_equal( [2, 2, 0, 0, 1, 1, 0], @parent1 ) 
    
  end

  def test_bit_nfo_not_found
    track2 = [
      Mapper::TrackNode.new( 'expr', 0, 6 ),
      Mapper::TrackNode.new( 'expr', 1, 4 ),
      Mapper::TrackNode.new( 'expr', 2, 2 ),
      Mapper::TrackNode.new( 'expr', 4, 4 ),
      Mapper::TrackNode.new( 'expr', 6, 6 )
    ]

    m = MutationBitStructural.new @grammar1
 
    m.random = MockRand.new []
    mutant = m.mutation( @parent1, track2 )

    assert_equal( @parent1, mutant )


    track3 = [
      Mapper::TrackNode.new( 'aop', 3, 3 ), 
      Mapper::TrackNode.new( 'aop', 5, 5 )
    ]

    m = MutationBitNodal.new @grammar1
 
    m.random = MockRand.new []
    mutant = m.mutation( @parent1, track3 )

    assert_equal( @parent1, mutant )
   
  end

  def  test_bit_codon
    m = MutationBitStructural.new nil
    assert_equal( 8, m.codon.bit_size )      
    m.codon = Mapper::CodonMod.new(5)
    assert_equal( 5, m.codon.bit_size )   
  
    m = MutationBitNodal.new nil
    assert_equal( 8, m.codon.bit_size )      
    m.codon = Mapper::CodonMod.new(5)
    assert_equal( 5, m.codon.bit_size )   
  end

  def test_basics
    m = MutationNodal.new @grammar1
 
    m.random = MockRand.new [{5=>3}, {3=>2}]
    mutant = m.mutation( @parent1, @track1 )

    assert_equal( [2, 2, 0, 0, 2, 1, 0], mutant )
    assert_equal( [2, 2, 0, 0, 1, 1, 0], @parent1 ) 
   
    m.random = MockRand.new [{5=>1}, {3=>0}]
    mutant = m.mutation( @parent1, @track1 )  

    assert_equal( [2, 0, 0, 0, 1, 1, 0], mutant )
    assert_equal( [2, 2, 0, 0, 1, 1, 0], @parent1 ) 


    m = MutationStructural.new @grammar1
 
    m.random = MockRand.new [{2=>1}, {3=>2}]
    mutant = m.mutation( @parent1, @track1 )

    assert_equal( [2, 2, 0, 0, 1, 2, 0], mutant )
    assert_equal( [2, 2, 0, 0, 1, 1, 0], @parent1 ) 
   
    m.random = MockRand.new [{2=>0}, {3=>1}]
    mutant = m.mutation( @parent1, @track1 )  

    assert_equal( [2, 2, 0, 1, 1, 1, 0], mutant )
    assert_equal( [2, 2, 0, 0, 1, 1, 0], @parent1 ) 
    
  end

  def test_magnitude
    m = MutationNodal.new @grammar1, 100
    assert_equal( 100, m.magnitude )
 
    m.random = MockRand.new [{5=>3}, {100=>20}]
    mutant = m.mutation( @parent1, @track1 )

    assert_equal( [2, 2, 0, 0, 20, 1, 0], mutant )
   
    m.magnitude = 42
    assert_equal( 42, m.magnitude )

    m.random = MockRand.new [{5=>1}, {42=>30}]
    mutant = m.mutation( @parent1, @track1 )  

    assert_equal( [2, 30, 0, 0, 1, 1, 0], mutant )


    m = MutationStructural.new @grammar1, 101
 
    m.random = MockRand.new [{2=>1}, {101=>22}]
    mutant = m.mutation( @parent1, @track1 )

    assert_equal( [2, 2, 0, 0, 1, 22, 0], mutant )

    m.magnitude = 422
    assert_equal( 422, m.magnitude )

   
    m.random = MockRand.new [{2=>0}, {422=>123}]
    mutant = m.mutation( @parent1, @track1 )  

    assert_equal( [2, 2, 0, 123, 1, 1, 0], mutant )
  end

  def test_nfo_not_found
    track2 = [
      Mapper::TrackNode.new( 'expr', 0, 6 ),
      Mapper::TrackNode.new( 'expr', 1, 4 ),
      Mapper::TrackNode.new( 'expr', 2, 2 ),
      Mapper::TrackNode.new( 'expr', 4, 4 ),
      Mapper::TrackNode.new( 'expr', 6, 6 )
    ]

    m = MutationStructural.new @grammar1
 
    m.random = MockRand.new []
    mutant = m.mutation( @parent1, track2 )

    assert_equal( @parent1, mutant )


    track3 = [
      Mapper::TrackNode.new( 'aop', 3, 3 ), 
      Mapper::TrackNode.new( 'aop', 5, 5 )
    ]

    m = MutationNodal.new @grammar1
 
    m.random = MockRand.new []
    mutant = m.mutation( @parent1, track3 )

    assert_equal( @parent1, mutant )
   
  end

 
end

