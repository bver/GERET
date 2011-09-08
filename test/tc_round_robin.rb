
$LOAD_PATH << '.'

require 'test/unit'
require 'test/mock_rand'
require 'lib/round_robin'

include Selection

class TC_RoundRobin < Test::Unit::TestCase

  def test_basic
    rr = RoundRobin.new [1, 2, 3]

    assert_equal( 1, rr.select_one )
    assert_equal( 2, rr.select_one )
    assert_equal( 3, rr.select_one )
    assert_equal( 1, rr.select_one )
    assert_equal( 2, rr.select_one )
 
    res = rr.select 5
    assert_equal( [3, 1, 2, 3, 1], res )
  end

end

