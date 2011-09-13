
$LOAD_PATH << '.' unless $LOAD_PATH.include? '.'

require 'test/unit'
require 'lib/dominance'

include Moea

class Point2D < Struct.new( :x, :y )
  def dominates? other
    (self.x >= other.x and self.y > other.y) or (self.x > other.x and self.y >= other.y)
  end
end

class SmartPoint < Point2D
  attr_accessor :smartRank, :smartCount, :smartDepth, :smartSpea 
end

class Cyclic <  Struct.new( :id, :dominated )
  def dominates? other
    other.id == self.dominated
  end
end

class WeakDominance < Struct.new( :x )
  def dominates? other
    self.x >= other.x
  end
end

class TC_Dominance < Test::Unit::TestCase

  def setup
    @population = []
    @population << Point2D.new( 2, 6 ) #a
    @population << Point2D.new( 3, 5 ) #b
    @population << Point2D.new( 5, 5 ) #c
    @population << Point2D.new( 1, 4 ) #d
    @population << Point2D.new( 4, 4 ) #e
    @population << Point2D.new( 7, 3 ) #f
    @population << Point2D.new( 4, 2 ) #g
    @population << Point2D.new( 3, 1 ) #h

    @population2 = @population.map { |pt| SmartPoint.new( pt.x, pt.y ) }
  end

  def test_rank_count_basic
    d = Dominance.new
    rankedPopulation = d.rank_count @population

    @population.each_index { |i| assert_equal( @population[i].object_id, rankedPopulation[i].original.object_id ) }

    assert_equal( 0, rankedPopulation[0].rank )
    assert_equal( 1, rankedPopulation[1].rank )
    assert_equal( 0, rankedPopulation[2].rank )
    assert_equal( 4, rankedPopulation[3].rank )
    assert_equal( 1, rankedPopulation[4].rank )
    assert_equal( 0, rankedPopulation[5].rank )
    assert_equal( 3, rankedPopulation[6].rank )   
    assert_equal( 5, rankedPopulation[7].rank )  

    assert_equal( 1, rankedPopulation[0].count )
    assert_equal( 2, rankedPopulation[1].count )
    assert_equal( 5, rankedPopulation[2].count )
    assert_equal( 0, rankedPopulation[3].count )
    assert_equal( 3, rankedPopulation[4].count )
    assert_equal( 2, rankedPopulation[5].count )
    assert_equal( 1, rankedPopulation[6].count )   
    assert_equal( 0, rankedPopulation[7].count )  

    assert_equal( 0,  rankedPopulation[0].spea ) #a nondominated
    assert_equal( 5,  rankedPopulation[1].spea ) #b dominated by c(5)
    assert_equal( 0,  rankedPopulation[2].spea ) #c nondominated
    assert_equal( 11, rankedPopulation[3].spea ) #d dominated by a(1) + b(2) + c(5) + e(3)
    assert_equal( 5,  rankedPopulation[4].spea ) #e dominated by c(5) 
    assert_equal( 0,  rankedPopulation[5].spea ) #f nondominated
    assert_equal( 10, rankedPopulation[6].spea ) #g dominated by c(5) + e(3) + f(2) 
    assert_equal( 13, rankedPopulation[7].spea ) #h dominated by b(2) + c(5) + e(3) + f(2) + g(1)
  end

  def test_rank_count_block
 
    d = Dominance.new
    d.rank_count( @population2 ) do |individual,rank,count,spea| 
       individual.smartRank = rank 
       individual.smartCount = count
       individual.smartSpea = spea
    end

    assert_equal( 0, @population2[0].smartRank )
    assert_equal( 1, @population2[1].smartRank )
    assert_equal( 0, @population2[2].smartRank )
    assert_equal( 4, @population2[3].smartRank )
    assert_equal( 1, @population2[4].smartRank )
    assert_equal( 0, @population2[5].smartRank )
    assert_equal( 3, @population2[6].smartRank )   
    assert_equal( 5, @population2[7].smartRank )  

    assert_equal( 1, @population2[0].smartCount )
    assert_equal( 2, @population2[1].smartCount )
    assert_equal( 5, @population2[2].smartCount )
    assert_equal( 0, @population2[3].smartCount )
    assert_equal( 3, @population2[4].smartCount )
    assert_equal( 2, @population2[5].smartCount )
    assert_equal( 1, @population2[6].smartCount )   
    assert_equal( 0, @population2[7].smartCount )  
  
    assert_equal( 0,  @population2[0].smartSpea ) #a nondominated
    assert_equal( 5,  @population2[1].smartSpea ) #b dominated by c(5)
    assert_equal( 0,  @population2[2].smartSpea ) #c nondominated
    assert_equal( 11, @population2[3].smartSpea ) #d dominated by a(1) + b(2) + c(5) + e(3)
    assert_equal( 5,  @population2[4].smartSpea ) #e dominated by c(5) 
    assert_equal( 0,  @population2[5].smartSpea ) #f nondominated
    assert_equal( 10, @population2[6].smartSpea ) #g dominated by c(5) + e(3) + f(2) 
    assert_equal( 13, @population2[7].smartSpea ) #h dominated by b(2) + c(5) + e(3) + f(2) + g(1)
   
  end
 
  def test_rank_count_empty_population
    d = Dominance.new
    rankedPopulation = d.rank_count []
    assert( rankedPopulation.empty? )
  end

  def test_rank_count_small_population
    d = Dominance.new
    rankedPopulation = d.rank_count [ Point2D.new( 3, 1 ) ]
    assert_equal( 0, rankedPopulation[0].rank )
    assert_equal( 0, rankedPopulation[0].count ) 
  end
 
  def test_depth_basic
    d = Dominance.new
    rankedPopulation = d.depth @population

    @population.each_index { |i| assert_equal( @population[i].object_id, rankedPopulation[i].original.object_id ) }

    assert_equal( 0, rankedPopulation[0].depth )
    assert_equal( 1, rankedPopulation[1].depth )
    assert_equal( 0, rankedPopulation[2].depth )
    assert_equal( 2, rankedPopulation[3].depth )
    assert_equal( 1, rankedPopulation[4].depth )
    assert_equal( 0, rankedPopulation[5].depth )
    assert_equal( 2, rankedPopulation[6].depth )   
    assert_equal( 3, rankedPopulation[7].depth )  
  end

  def test_depth_block
    d = Dominance.new
    d.depth( @population2 ) { |individual,depth| individual.smartDepth = depth }

    assert_equal( 0, @population2[0].smartDepth )
    assert_equal( 1, @population2[1].smartDepth )
    assert_equal( 0, @population2[2].smartDepth )
    assert_equal( 2, @population2[3].smartDepth )
    assert_equal( 1, @population2[4].smartDepth )
    assert_equal( 0, @population2[5].smartDepth )
    assert_equal( 2, @population2[6].smartDepth )   
    assert_equal( 3, @population2[7].smartDepth )  
  end
 
  def test_depth_empty_population
    d = Dominance.new
    rankedPopulation = d.depth []
    assert( rankedPopulation.empty? )
  end

  def test_depth_small_population
    d = Dominance.new
    rankedPopulation = d.depth [ Point2D.new( 3, 1 ) ]
    assert_equal( 0, rankedPopulation[0].depth )
  end
  
  def test_cyclic_dominance

    rock = Cyclic.new( :rock, :scissors )
    scissors = Cyclic.new( :scissors, :paper ) 
    paper = Cyclic.new( :paper, :rock )  

    assert_equal( true, rock.dominates?( scissors ) ) 
    assert_equal( false, rock.dominates?( paper ) )
    assert_equal( true, scissors.dominates?( paper ) ) 
    assert_equal( false, scissors.dominates?( rock ) )
    assert_equal( true, paper.dominates?( rock ) ) 
    assert_equal( false, paper.dominates?( scissors ) ) 

    population = [ rock, scissors, paper]  

    d = Dominance.new
    rankedPopulation = d.rank_count population   

    assert_equal( 1, rankedPopulation[0].rank )
    assert_equal( 1, rankedPopulation[1].rank )
    assert_equal( 1, rankedPopulation[2].rank )

    assert_equal( 1, rankedPopulation[0].count )
    assert_equal( 1, rankedPopulation[1].count )
    assert_equal( 1, rankedPopulation[2].count )
  
    exception = assert_raise( RuntimeError ) { d.depth population }
    assert_equal( "Dominance: possibly cyclic dominance found", exception.message )
  end

  def test_depth_max
    d = Dominance.new
    assert_equal( nil, d.at_least )
    d.at_least = 4
    assert_equal( 4, d.at_least )
   
    rankedPopulation = d.depth @population 

    @population.each_index { |i| assert_equal( @population[i].object_id, rankedPopulation[i].original.object_id ) }

    assert_equal( 0, rankedPopulation[0].depth )
    assert_equal( 1, rankedPopulation[1].depth )
    assert_equal( 0, rankedPopulation[2].depth )
    assert_equal( nil, rankedPopulation[3].depth )
    assert_equal( 1, rankedPopulation[4].depth )
    assert_equal( 0, rankedPopulation[5].depth )
    assert_equal( nil, rankedPopulation[6].depth )   
    assert_equal( nil, rankedPopulation[7].depth )  

    d.at_least = 6
    assert_equal( 6, d.at_least )
   
    d.depth( @population2 ) { |individual,depth| individual.smartDepth = depth }

    assert_equal( 0, @population2[0].smartDepth )
    assert_equal( 1, @population2[1].smartDepth )
    assert_equal( 0, @population2[2].smartDepth )
    assert_equal( 2, @population2[3].smartDepth )
    assert_equal( 1, @population2[4].smartDepth )
    assert_equal( 0, @population2[5].smartDepth )
    assert_equal( 2, @population2[6].smartDepth )   
    assert_equal( nil, @population2[7].smartDepth )  

    d.at_least = 2
    assert_equal( 2, d.at_least )
   
    rankedPopulation = d.depth @population 

    @population.each_index { |i| assert_equal( @population[i].object_id, rankedPopulation[i].original.object_id ) }

    assert_equal( 0, rankedPopulation[0].depth )
    assert_equal( nil, rankedPopulation[1].depth )
    assert_equal( 0, rankedPopulation[2].depth )
    assert_equal( nil, rankedPopulation[3].depth )
    assert_equal( nil, rankedPopulation[4].depth )
    assert_equal( 0, rankedPopulation[5].depth )
    assert_equal( nil, rankedPopulation[6].depth )   
    assert_equal( nil, rankedPopulation[7].depth )  

    d.at_least = @population.size 
    assert_equal( @population.size, d.at_least )
    rankedPopulation = d.depth @population

    @population.each_index { |i| assert_equal( @population[i].object_id, rankedPopulation[i].original.object_id ) }

    assert_equal( 0, rankedPopulation[0].depth )
    assert_equal( 1, rankedPopulation[1].depth )
    assert_equal( 0, rankedPopulation[2].depth )
    assert_equal( 2, rankedPopulation[3].depth )
    assert_equal( 1, rankedPopulation[4].depth )
    assert_equal( 0, rankedPopulation[5].depth )
    assert_equal( 2, rankedPopulation[6].depth )   
    assert_equal( 3, rankedPopulation[7].depth )  
  end

  def test_layers
    d = Dominance.new
    assert_equal( nil, d.at_least )

    fronts = d.layers @population
    assert_equal( 4, fronts.size )
    assert_equal( 3, fronts[0].size )
    assert( fronts[0].include?( @population[0] ))
    assert( fronts[0].include?( @population[2] ))
    assert( fronts[0].include?( @population[5] ))
    assert_equal( 2, fronts[1].size )
    assert( fronts[1].include?( @population[1] ))
    assert( fronts[1].include?( @population[4] ))
    assert_equal( 2, fronts[2].size )
    assert( fronts[2].include?( @population[3] ))
    assert( fronts[2].include?( @population[6] ))
    assert_equal( [ @population[7] ], fronts[3] )
   
    d.at_least = 4
    fronts = d.layers @population 

    assert_equal( 2, fronts.size )
    assert_equal( 3, fronts[0].size )
    assert( fronts[0].include?( @population[0] ))
    assert( fronts[0].include?( @population[2] ))
    assert( fronts[0].include?( @population[5] ))
    assert_equal( 2, fronts[1].size )
    assert( fronts[1].include?( @population[1] ))
    assert( fronts[1].include?( @population[4] ))

    d.at_least = 2
    fronts = d.layers @population 

    assert_equal( 1, fronts.size )
    assert_equal( 3, fronts[0].size )
    assert( fronts[0].include?( @population[0] ))
    assert( fronts[0].include?( @population[2] ))
    assert( fronts[0].include?( @population[5] ))
   
    d.at_least = @population.size 
    fronts = d.layers @population

    assert_equal( 4, fronts.size )
    assert_equal( 3, fronts[0].size )
    assert( fronts[0].include?( @population[0] ))
    assert( fronts[0].include?( @population[2] ))
    assert( fronts[0].include?( @population[5] ))
    assert_equal( 2, fronts[1].size )
    assert( fronts[1].include?( @population[1] ))
    assert( fronts[1].include?( @population[4] ))
    assert_equal( 2, fronts[2].size )
    assert( fronts[2].include?( @population[3] ))
    assert( fronts[2].include?( @population[6] ))
    assert_equal( [ @population[7] ], fronts[3] )
  end

  def test_weak_dominance
    a = WeakDominance.new( 1 )   
    b = WeakDominance.new( 2 ) 
    c = WeakDominance.new( 2 )   
    d = WeakDominance.new( 3 )   

    assert( d.dominates?( b ) )
    assert( d.dominates?( c ) )   
    assert( b.dominates?( a ) )
    assert( c.dominates?( a ) )
    assert( b.dominates?( c ) )
    assert( c.dominates?( b ) )
    assert( a.dominates?( a ) )
    assert( !a.dominates?( b ) )
    assert( !a.dominates?( c ) )   
    assert( !b.dominates?( d ) )
    assert( !c.dominates?( d ) )  

    population = [ a, b, c, d ]

    d = Dominance.new  
    rankedPopulation = d.rank_count population   

    assert_equal( 4, rankedPopulation[0].rank )
    assert_equal( 3, rankedPopulation[1].rank )
    assert_equal( 3, rankedPopulation[2].rank )
    assert_equal( 1, rankedPopulation[3].rank )

    assert_equal( 1, rankedPopulation[0].count )
    assert_equal( 3, rankedPopulation[1].count )
    assert_equal( 3, rankedPopulation[2].count )
    assert_equal( 4, rankedPopulation[3].count )
  end

end

