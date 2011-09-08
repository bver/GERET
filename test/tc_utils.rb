
$LOAD_PATH << '.'

require 'test/unit'
require 'lib/utils'
require 'test/mock_rand'

class TC_Utils < Test::Unit::TestCase

  def test_stats
    a = [3, 3, nil, 4, nil, 4, 2]
    assert_equal( [2, 4, 16.0/5, 5], Util.statistics(a) )

    n = [nil, nil]
    assert_equal( [nil, nil, nil, 0], Util.statistics(n) )

    a = ['3', '4', '2']
    assert_equal( [2, 4, 3.0, 3], Util.statistics(a) { |item| item.to_i } )   

    a = [3, 4, 3.3/0.0, 2]
    assert_equal( [2, 1/0.0, 3.0, 3], Util.statistics(a) )

    a = [3, 3, 3.3/0.0, 4, nil, 4, 2]
    assert_equal( [2, 1/0.0, 16.0/5, 5], Util.statistics(a) )
  end
  
  def test_diversity
    a = [3, 3, nil, 4, 5, 4, 2, 4]
    assert_equal( [3, 2, 1, 1, 1], Util.diversity(a) )

    a = [3, -3, 4, 5, -4, 2, -4]
    assert_equal( [3, 2, 1, 1], Util.diversity(a) { |item| item.abs } )
  end

  def test_percent
    assert_equal( 'N/A%', Util.percent(1,0) )
    assert_equal( '10%', Util.percent(1,10) )
  end

  def test_permutation
    r = MockRand.new [ {5=>3}, {4=>1}, {3=>1}, {2=>0}, {1=>0} ]
    p = Util.permutate( [1, 2, 3, 4, 5], r )
    assert_equal( [4, 2, 3, 1, 5], p )
  end

end

