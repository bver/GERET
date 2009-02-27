#!/usr/bin/ruby

require 'test/unit'
require 'lib/pareto'

class SingleMax < Struct.new( :value )
  include Pareto
  Pareto.objective :SingleMax, :value, :maximize   
end

class SingleMin
  include Pareto
  Pareto.objective :SingleMin, :value, :minimize

  def initialize initvalue
    @val = initvalue
  end

  def value
    @val
  end
end

class BasicPair < Struct.new( :up, :down )
  include Pareto
  Pareto.objective :BasicPair, :down, :minimize
  Pareto.objective :BasicPair, :up, :maximize 
end

class TC_Pareto < Test::Unit::TestCase

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
    assert_equal( 1, i2 <=> i3 )
    assert_equal( -1, i3 <=> i2 )
  
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
    assert_equal( -1, i2 <=> i3 )
    assert_equal( 1, i3 <=> i2 )
  
  end

  def test_basic_pair

    i1 = BasicPair.new 42, -30
    i2 = BasicPair.new 30, -42   
    assert_equal( 0, i1 <=> i2 )
    assert_equal( 0, i2 <=> i1 )

    i3 = BasicPair.new 42, -42  
    assert_equal( 1, i3 <=> i1 )
    assert_equal( -1, i1 <=> i3 )
    assert_equal( 1, i3 <=> i2 )
    assert_equal( -1, i2 <=> i3 )

    i4 = BasicPair.new 30, -30 
    assert_equal( -1, i4 <=> i1 )
    assert_equal( 1, i1 <=> i4 )
    assert_equal( -1, i4 <=> i2 )
    assert_equal( 1, i2 <=> i4 )

    i5 = BasicPair.new 30, -30   
    assert_equal( 0, i5 <=> i4 )
    assert_equal( 0, i4 <=> i5 )
 
  end
 
end

