
$LOAD_PATH << '.' unless $LOAD_PATH.include? '.'

require 'test/unit'
require 'lib/individual'

include Util

class MockMapper
  def initialize
    @used_length = 5
    @complexity = 9
  end

  def phenotype genotype 
    genotype.size > 3 ? "some creative phenotype" : nil
  end

  def track_support
    ['track']
  end
  
  attr_reader :used_length, :complexity
end

class TC_Individual < Test::Unit::TestCase
  
  def setup
    @mapper = MockMapper.new
  end

  def test_basic
    individual = Individual.new( @mapper, [1, 2, 3, 4, 5, 6, 7]  )
    assert_equal( [1, 2, 3, 4, 5, 6, 7], individual.genotype )
    assert_equal( "some creative phenotype", individual.phenotype )
    assert_equal( 5, individual.used_length )
    assert_equal( 9, individual.complexity )
    assert_equal( true, individual.valid? )

    individual.shorten_chromozome = false
    assert_equal( [1, 2, 3, 4, 5, 6, 7], individual.genotype )
    individual.shorten_chromozome = true
    assert_equal( [1, 2, 3, 4, 5], individual.genotype )
  end 

  def test_invalid
    individual = Individual.new( @mapper, [1, 2]  )
    assert_equal( [1, 2], individual.genotype )
    assert_equal( nil, individual.phenotype )
    assert_equal( false, individual.valid? )
  end
  
  def test_track_support
    individual = Individual.new( @mapper, [1, 2, 3, 4, 5, 6, 7] )
    assert_equal( ['track'], individual.track_support )
  end

end

