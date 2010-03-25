#!/usr/bin/ruby

require 'lib/alps.rb'
require 'test/unit'

include Util

class Individ
  include Alps
end

class TC_Utils < Test::Unit::TestCase

  def test_basic
    i1 = Individ.new
    assert_equal( 0, i1.age )
    
    i2 = Individ.new
    i2.parents( i1 )
    assert_equal( 1, i2.age )

    i3 = Individ.new
    i3.parents( i1, i2 )
    assert_equal( 2, i3.age )

    i4 = Individ.new
    i4.parents( i1, i1 )
    assert_equal( 1, i4.age )
  end

  def test_aging_scheme

    Alps.age_gap( 10 )
    Alps.aging_scheme( :linear )
    Alps.layers( 5 )
    assert_equal( [10,20,30,40,50], Alps.age_limits )

    Alps.age_gap( 1 )
    Alps.aging_scheme( :polynomial )
    Alps.layers( 7 )
    assert_equal( [1, 4, 9, 16, 25, 36, 49], Alps.age_limits )

    Alps.age_gap( 1 )
    Alps.aging_scheme( :fibonacci )
    Alps.layers( 7 )
    assert_equal( [1,2,3,5,8,13,21], Alps.age_limits )

    Alps.age_gap( 10 )
    Alps.aging_scheme( :exponential )
    Alps.layers( 6 )
    assert_equal( [10,20,40,80,160,320], Alps.age_limits )

  end

  def test_scheme_not_supported
    Alps.age_gap( 10 )
    Alps.aging_scheme( :unknown )
    Alps.layers( 5 )
    exception = assert_raise( RuntimeError ) { Alps.age_limits }
    assert_equal( "Alps: a scheme 'unknown' not supported", exception.message )
  end

  def test_not_enough_layers
    exception = assert_raise( RuntimeError ) { Alps.layers(1) }
    assert_equal( "Alps: not enough layers, needed at least 2", exception.message )
  end

  def test_layers
    Alps.age_gap( 10 )
    Alps.aging_scheme( :linear )
    Alps.layers( 3 )
    assert_equal( [10,20,30], Alps.age_limits )

    i1 = Individ.new
    assert_equal( 0, i1.age )
    assert_equal( 0, i1.layer ) 

    10.times { i1.parents( i1 ) }
    assert_equal( 10, i1.age )
    assert_equal( 0, i1.layer ) 
    
    i1.parents( i1 )
    assert_equal( 11, i1.age )
    assert_equal( 1, i1.layer ) 

    9.times { i1.parents( i1 ) }
    assert_equal( 20, i1.age )
    assert_equal( 1, i1.layer ) 

    i1.parents( i1 )
    assert_equal( 21, i1.age )
    assert_equal( 2, i1.layer ) 

    9.times { i1.parents( i1 ) }
    assert_equal( 30, i1.age )
    assert_equal( 2, i1.layer ) 

    42.times { i1.parents( i1 ) }
    assert_equal( 72, i1.age )
    assert_equal( 2, i1.layer ) 
  end
end

