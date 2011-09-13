
$LOAD_PATH << '.' unless $LOAD_PATH.include? '.'

require 'test/unit'
require 'lib/store'

include Util

StoredIndividual = Struct.new( 'StoredIndividual', :chromozome ) 

class TC_Config < Test::Unit::TestCase
  def test_basic
    population = []
    population << StoredIndividual.new( [1,2,3] )
    population << StoredIndividual.new( [4,5,6,7] )
    population << StoredIndividual.new( [9,10] )

    saver = Store.new 'test/data/store.bin'
    saver.save population
 
    loader = Store.new 'test/data/store.bin' 
    loaded_population = loader.load 

    assert_equal( population, loaded_population )
  end

  def test_filenames
    saver = Store.new 'dummy'
    assert_equal( 'dummy', saver.filename )

    saver = Store.new
    assert_equal( nil, saver.filename )
  
    saver.filename = 'test/data/store2.bin'
    assert_equal( 'test/data/store2.bin', saver.filename )

    saver.save 'hello'

    loader = Store.new 'test/data/store2.bin'
    assert_equal( 'test/data/store2.bin', loader.filename )

    assert_equal( 'hello', loader.load )
  end

  def test_nonexistent_file
    loader = Store.new 'test/data/nonexistent.bin' 
    assert_equal( nil, loader.load )
  end

end

