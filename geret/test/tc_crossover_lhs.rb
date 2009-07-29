#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/crossover_lhs'

include Operator

class TC_CrossoverLHS < Test::Unit::TestCase
  
  def test_basics
    c = CrossoverLHS.new
    c.random = MockRand.new [{2=>1}, {5=>1}, {5=>2}]  

    parent1 = [2,   2, 0, 0, 1,   1, 0]
    track1 = [
      Mapper::TrackNode.new( 'expr', 0, 6 ),
      Mapper::TrackNode.new( 'expr', 1, 4 ), #1st
      Mapper::TrackNode.new( 'expr', 2, 2 ),
      Mapper::TrackNode.new( 'aop', 3, 3 ),  #2nd 
      Mapper::TrackNode.new( 'expr', 4, 4 ),
      Mapper::TrackNode.new( 'aop', 5, 5 ),
      Mapper::TrackNode.new( 'expr', 6, 6 )
    ]

    parent2 = [2, 4, 3,   5, 0, 6, 1,   3, 5] 
    track2 = [
      Mapper::TrackNode.new( 'expr', 0, 6 ),
      Mapper::TrackNode.new( 'expr', 1, 1 ),
      Mapper::TrackNode.new( 'aop', 2, 2 ),
      Mapper::TrackNode.new( 'expr', 3, 6 ), #1st
      Mapper::TrackNode.new( 'expr', 4, 4 ),     
      Mapper::TrackNode.new( 'aop', 5, 5 ),  #2nd   
      Mapper::TrackNode.new( 'expr', 6, 6 ),          
    ]

    offspring1, offspring2 = c.crossover( parent1, parent2, track1, track2 )

    assert_equal( [2, 5, 0, 6, 1, 1, 0 ], offspring1 )
    assert_equal( [2, 4, 3, 2, 0, 0, 1, 3, 5], offspring2 ) 
    offspring1[0] = nil
    assert_equal( [2, 2, 0, 0, 1, 1, 0], parent1 ) # do not spoil parents
    assert_equal( [2, 4, 3, 5, 0, 6, 1, 3, 5], parent2 ) # do not spoil parents

    # now 'aop':
    c.random = MockRand.new [{2=>0}, {2=>0}, {2=>1}]  
    offspring1, offspring2 = c.crossover( parent1, parent2, track1, track2 )
    assert_equal( [2, 2, 0,   6,   1, 1, 0], offspring1 )
    assert_equal( [2, 4, 3, 5, 0,   0,   1, 3, 5], offspring2 )   
    assert_equal( [2, 2, 0, 0, 1, 1, 0], parent1 ) # do not spoil parents
    assert_equal( [2, 4, 3, 5, 0, 6, 1, 3, 5], parent2 ) # do not spoil parents
  end

  def test_unusable_hint
    c = CrossoverLHS.new

    parent1 = [2,   2, 0, 0, 1,   1, 0]
    track1 = [
      Mapper::TrackNode.new( 'some', 0, 6 ),
      Mapper::TrackNode.new( 'another', 1, 4 )
    ]

    parent2 = [2, 4, 3,   5, 0, 6, 1,   3, 5] 
    track2 = [
      Mapper::TrackNode.new( 'no', 0, 3 ),
      Mapper::TrackNode.new( 'compatibility', 1, 1 ) 
    ]

    offspring1, offspring2 = c.crossover( parent1, parent2, track1, track2 )

    assert_equal( parent1, offspring1 ) # clone parents as fallback solution
    assert_equal( parent2, offspring2 ) # clone parents as fallback solution  
    assert( parent1.object_id != offspring1.object_id ) 
    assert( parent2.object_id != offspring2.object_id )    
    assert_equal( [2, 2, 0, 0, 1, 1, 0], parent1 ) # do not spoil parents
    assert_equal( [2, 4, 3, 5, 0, 6, 1, 3, 5], parent2 ) # do not spoil parents
  end
 
end

