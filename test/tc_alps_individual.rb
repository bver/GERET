
$LOAD_PATH << '.' unless $LOAD_PATH.include? '.'

require 'lib/alps_individual'
require 'test/unit'

include Util

class Individ
  include AlpsIndividual
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

    AlpsIndividual.age_gap( 10 )
    AlpsIndividual.aging_scheme( :linear )
    AlpsIndividual.layers( 5 )
    assert_equal( [10,20,30,40,50], AlpsIndividual.age_limits )

    AlpsIndividual.age_gap( 1 )
    AlpsIndividual.aging_scheme( :polynomial )
    AlpsIndividual.layers( 7 )
    assert_equal( [1, 4, 9, 16, 25, 36, 49], AlpsIndividual.age_limits )

    AlpsIndividual.age_gap( 1 )
    AlpsIndividual.aging_scheme( :fibonacci )
    AlpsIndividual.layers( 7 )
    assert_equal( [1,2,3,5,8,13,21], AlpsIndividual.age_limits )

    AlpsIndividual.age_gap( 10 )
    AlpsIndividual.aging_scheme( :exponential )
    AlpsIndividual.layers( 6 )
    assert_equal( [10,20,40,80,160,320], AlpsIndividual.age_limits )

  end

  def test_scheme_not_supported
    AlpsIndividual.age_gap( 10 )
    AlpsIndividual.aging_scheme( :unknown )
    AlpsIndividual.layers( 5 )
    exception = assert_raise( RuntimeError ) { AlpsIndividual.age_limits }
    assert_equal( "AlpsIndividual: a scheme 'unknown' not supported", exception.message )
  end

  def test_not_enough_layers
    exception = assert_raise( RuntimeError ) { AlpsIndividual.layers(1) }
    assert_equal( "AlpsIndividual: not enough layers, needed at least 2", exception.message )
  end

  def test_layers
    AlpsIndividual.age_gap( 10 )
    AlpsIndividual.aging_scheme( :linear )
    AlpsIndividual.layers( 3 )
    assert_equal( [10,20,30], AlpsIndividual.age_limits )

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
    assert_equal( 3, i1.layer ) 
  end
end

