
$LOAD_PATH << '.'

require 'test/unit'
require 'lib/pareto'

include Moea

class SingleMax < Struct.new( :value )
  include Pareto
  objective :value, :maximize   
end

class SingleMaxWeak < Struct.new( :value )
  include WeakPareto
  objective :value, :maximize   
end

class SingleMin
  include Pareto

  def initialize initvalue
    @val = initvalue
  end

  def value
    @val
  end
end
Pareto.objective SingleMin, :value, :minimize

class BasicPair < Struct.new( :up, :down )
  include Pareto
  objective :down, :minimize
  Pareto.objective BasicPair, :up, :maximize 
end

class ClearPair < Struct.new( :up, :down )
  include Pareto
  minimize :down
  maximize :up 
end

class BasicPairWeak < Struct.new( :up, :down )
  include WeakPareto
  minimize :down
  objective :up, :maximize 
end

class SingleProcMin < Struct.new( :data )
  include Pareto
  objective :data, proc { |one,two| two.data.size <=> one.data.size }
end

class BasicPairFancy < Struct.new( :up, :down )
  include Pareto
  Pareto.minimize BasicPairFancy, :down
  maximize :up 
end

class PointPareto < Struct.new( :id, :x, :y )
  def dominates? other
    (self.x >= other.x and self.y > other.y) or (self.x > other.x and self.y >= other.y)
  end
end

class TC_Pareto < Test::Unit::TestCase

  def setup
    @population = []
    @population << PointPareto.new( 'a', 2, 6 ) # rank 0
    @population << PointPareto.new( 'b', 3, 5 ) # rank 1    
    @population << PointPareto.new( 'c', 5, 5 ) # rank 0
    @population << PointPareto.new( 'd', 1, 4 ) # rank 4
    @population << PointPareto.new( 'e', 4, 4 ) # rank 1
    @population << PointPareto.new( 'f', 7, 3 ) # rank 0
    @population << PointPareto.new( 'g', 4, 2 ) # rank 3
    @population << PointPareto.new( 'h', 3, 1 ) # rank 5 
  end
 
  def test_basic_max
    
    i1 = SingleMax.new 42
    i2 = SingleMax.new 42   
    i3 = SingleMax.new 40  

    assert_equal( false, i1.dominates?( i2 ) )
    assert_equal( false, i2.dominates?( i1 ) )
    assert_equal( true, i2.dominates?( i3 ) )
    assert_equal( false, i3.dominates?( i2 ) )

    assert_equal( 0, i1 <=> i2 )
    assert_equal( 0, i2 <=> i1 )
    assert_equal( -1, i2 <=> i3 )
    assert_equal( 1, i3 <=> i2 )
  
  end

  def test_basic_min
    
    i1 = SingleMin.new 42
    i2 = SingleMin.new 42   
    i3 = SingleMin.new 40  

    assert_equal( false, i1.dominates?( i2 ) )
    assert_equal( false, i2.dominates?( i1 ) )
    assert_equal( false, i2.dominates?( i3 ) )
    assert_equal( true, i3.dominates?( i2 ) )

    assert_equal( 0, i1 <=> i2 )
    assert_equal( 0, i2 <=> i1 )
    assert_equal( 1, i2 <=> i3 )
    assert_equal( -1, i3 <=> i2 )
  
  end

  def test_basic_pair

    i1 = BasicPair.new 42, -30
    i2 = BasicPair.new 30, -42   
    assert_equal( 0, i1 <=> i2 )
    assert_equal( 0, i2 <=> i1 )

    i3 = BasicPair.new 42, -42  
    assert_equal( -1, i3 <=> i1 )
    assert_equal( 1, i1 <=> i3 )
    assert_equal( -1, i3 <=> i2 )
    assert_equal( 1, i2 <=> i3 )

    i4 = BasicPair.new 30, -30 
    assert_equal( 1, i4 <=> i1 )
    assert_equal( -1, i1 <=> i4 )
    assert_equal( 1, i4 <=> i2 )
    assert_equal( -1, i2 <=> i4 )

    i5 = BasicPair.new 30, -30   
    assert_equal( 0, i5 <=> i4 )
    assert_equal( 0, i4 <=> i5 )
    assert_equal( false, i5.dominates?( i4 ) )
    assert_equal( false, i4.dominates?( i5 ) ) 
 
  end

  def test_proc_min
    
    i1 = SingleProcMin.new [1,3,0,5]
    i2 = SingleProcMin.new [nil, '', 'ok', nil]
    i3 = SingleProcMin.new [1000,"2000"]  

    assert( i3.dominates?( i1 ) )
    assert( i3.dominates?( i2  ) ) 
    assert( ! i1.dominates?( i2 ) )  
    assert( ! i2.dominates?( i1 ) ) 

    assert_equal( 0, i1 <=> i2 )
    assert_equal( 0, i2 <=> i1 )
    assert_equal( 1, i2 <=> i3 )
    assert_equal( -1, i3 <=> i2 )
  
  end

  def test_pair_fancy

    i1 = BasicPairFancy.new 42, -30
    i2 = BasicPairFancy.new 30, -42   
    assert_equal( 0, i1 <=> i2 )
    assert_equal( 0, i2 <=> i1 )

    i3 = BasicPairFancy.new 42, -42  
    assert_equal( -1, i3 <=> i1 )
    assert_equal( 1, i1 <=> i3 )
    assert_equal( -1, i3 <=> i2 )
    assert_equal( 1, i2 <=> i3 )

    i4 = BasicPairFancy.new 30, -30 
    assert_equal( 1, i4 <=> i1 )
    assert_equal( -1, i1 <=> i4 )
    assert_equal( 1, i4 <=> i2 )
    assert_equal( -1, i2 <=> i4 )

    i5 = BasicPairFancy.new 30, -30   
    assert_equal( 0, i5 <=> i4 )
    assert_equal( 0, i4 <=> i5 )
 
  end

  def test_pareto_objective_symbols
    assert_equal( [:down, :up], Pareto.objective_symbols( BasicPair ) )
    assert_equal( [:down, :up], BasicPair.new.objective_symbols )
    assert_equal( [:data], SingleProcMin.new.objective_symbols )
  end

  def test_clear_objectives
    assert_equal( [:down, :up], Pareto.objective_symbols( ClearPair ) )
    Pareto.objective ClearPair, :newone, :maximize
    assert_equal( [:down, :up, :newone], Pareto.objective_symbols( ClearPair ) )
    Pareto.clear_objectives ClearPair   
    assert_equal( [], Pareto.objective_symbols( ClearPair ) )  
    Pareto.objective ClearPair, :newone, :maximize   
    assert_equal( [:newone], Pareto.objective_symbols( ClearPair ) ) 
  end
 
  def test_objective_sorting
    population = []
    population << BasicPair.new( 42, -30 )
    population << BasicPair.new( 30, -12 )
    population << BasicPair.new(  5, -32 )
    population << BasicPair.new( 25, -10 )

    ups = Pareto.objective_sort( population, BasicPair, :up )
    assert_equal( 4, ups.size ) 
    assert_equal( population[0], ups[0] )
    assert_equal( population[1], ups[1] )
    assert_equal( population[3], ups[2] )   
    assert_equal( population[2], ups[3] )

    downs = Pareto.objective_sort( population, BasicPair, :down )
    assert_equal( 4, downs.size ) 
    assert_equal( population[2], downs[0] )
    assert_equal( population[0], downs[1] )
    assert_equal( population[1], downs[2] )   
    assert_equal( population[3], downs[3] )
  end

  def test_objective_best
    population = []
    population << BasicPair.new( 42, -30 )
    population << BasicPair.new( 30, -12 )
    population << BasicPair.new(  5, -32 )
    population << BasicPair.new( 25, -10 )

    up = Pareto.objective_best( population, BasicPair, :up )
    assert_equal( population[0], up )

    down = Pareto.objective_best( population, BasicPair, :down )
    assert_equal( population[2], down )
  end

  def test_nondominated
    front = Pareto.nondominated @population
    assert_equal( 3, front.size )
    assert_equal( 'a', front[0].id )   
    assert_equal( 'c', front[1].id )
    assert_equal( 'f', front[2].id )   
  end

  def test_dominated
    dominated = Pareto.dominated @population
    assert_equal( 5, dominated.size )
    assert_equal( 'b', dominated[0].id )   
    assert_equal( 'd', dominated[1].id )
    assert_equal( 'e', dominated[2].id )      
    assert_equal( 'g', dominated[3].id )   
    assert_equal( 'h', dominated[4].id )      
  end

  def test_dominated_bugfix
    orig_size = @population.size 
    Pareto.dominated @population
    assert_equal( orig_size, @population.size )
  end

  def test_basic_max_weak
    
    i1 = SingleMaxWeak.new 42
    i2 = SingleMaxWeak.new 42   
    i3 = SingleMaxWeak.new 40  
    i4 = SingleMaxWeak.new 44

    assert_equal( true, i1.dominates?( i2 ) )
    assert_equal( true, i2.dominates?( i1 ) )
    assert_equal( true, i2.dominates?( i3 ) )
    assert_equal( false, i3.dominates?( i2 ) )
    assert_equal( true, i4.dominates?( i3 ) )
    assert_equal( true, i4.dominates?( i4 ) )
    assert_equal( false, i3.dominates?( i4 ) )
  
    assert_equal( 0, i1 <=> i2 )
    assert_equal( 0, i2 <=> i1 )
    assert_equal( -1, i2 <=> i3 )
    assert_equal( 1, i3 <=> i2 )

    population = [i1, i2, i3, i4] 
    dominated = Pareto.dominated population 
    assert_equal( 3, dominated.size )
    assert( dominated.include?( i1 ) )
    assert( dominated.include?( i2 ) )    
    assert( dominated.include?( i3 ) ) 
    nonominated = Pareto.nondominated population 
    assert_equal( [i4], nonominated )

    population = [i1, i2, i3] 
    dominated = Pareto.dominated population 
    assert_equal( population.size, dominated.size )
    assert( dominated.include?( i1 ) )
    assert( dominated.include?( i2 ) )    
    assert( dominated.include?( i3 ) ) 
    nonominated = Pareto.nondominated population 
    assert_equal( [], nonominated )

  end

  def test_weak_bugfix
    duplicate = SingleMaxWeak.new 42
    pop = [ duplicate, duplicate ]
    assert_equal( [], Pareto.nondominated( pop ) )
  end

  def test_basic_pair_weak

    i1 = BasicPairWeak.new 42, -30
    i4 = BasicPairWeak.new 30, -30 
    assert_equal( 1, i4 <=> i1 )
    assert_equal( -1, i1 <=> i4 )

    i5 = BasicPairWeak.new 30, -30   
    assert_equal( 0, i5 <=> i4 )
    assert_equal( 0, i4 <=> i5 )
    assert_equal( true, i5.dominates?( i4 ) )
    assert_equal( true, i4.dominates?( i5 ) ) 

  end
 
end

