
$LOAD_PATH << '.'

require 'test/unit'
require 'test/mock_rand'
require 'lib/codon_gray'

class TC_CodonGray < Test::Unit::TestCase

  def setup
    @gray3 = [0,1,3,2,6,7,5,4]
    @gray2 = [0,1,3,2]
  end

  def test_bitsize
    c = Mapper::CodonGray.new
    assert_equal( 8, c.bit_size )

    c.bit_size = 3
    assert_equal( 3, c.bit_size )

    assert_equal( 2, c.interpret( 3, @gray3[5] ) )   
    assert_equal( 0, c.interpret( 3, @gray3[6] ) )      
    assert_equal( 3, c.interpret( 4, @gray3[7] ) )         
   
    c.random = MockRand.new [ {2=>1}, {2=>1} ]

    assert_equal( @gray3[5], c.generate( 3, 2 ) )
    assert_equal( @gray3[3], c.generate( 3, 0 ) )

    c.bit_size = 2
    assert_equal( 2, c.bit_size )

    assert_equal( 2, c.interpret( 3, @gray2[2] ) )   
    assert_equal( 1, c.interpret( 3, @gray2[1] ) )      
   
    c.random = MockRand.new [ {1=>0}, {1=>0} ]

    assert_equal( @gray2[2], c.generate( 3, 2 ) )
    assert_equal( @gray2[1], c.generate( 3, 1 ) )
  end
 

end

