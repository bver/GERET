
$LOAD_PATH << '.' unless $LOAD_PATH.include? '.'

require 'test/unit'
require 'test/mock_rand'
require 'lib/random_init'

include Operator

class TC_RandomInit < Test::Unit::TestCase

  def test_basic
    init = RandomInit.new
    assert_equal( 8, init.codon.bit_size )

    init.random =  MockRand.new [{256=>3}, {256=>0}, {256=>8}, {256=>5}]
    assert_equal( [3, 0, 8, 5], init.init(4) )

    init.codon = CodonMod.new 3
    assert_equal( 3, init.codon.bit_size )

    init.random =  MockRand.new [{8=>3}, {8=>0}, {8=>7}, {8=>5}]
    assert_equal( [3, 0, 7, 5], init.init(4) )
  end

end

