#!/usr/bin/ruby

require 'test/unit'
require 'lib/utils'

class TC_Utils < Test::Unit::TestCase

  def test_stats
    a = [3, 3, nil, 4, nil, 4, 2]
    assert_equal( [2, 4, 16.0/5, 5], Utils.statistics(a) )

    n = [nil, nil]
    assert_equal( [nil, nil, nil, 0], Utils.statistics(n) )

    a = ['3', '4', '2']
    assert_equal( [2, 4, 3.0, 3], Utils.statistics(a) { |item| item.to_i } )   
  end
  
  def test_diversity
    a = [3, 3, nil, 4, 5, 4, 2, 4]
    assert_equal( [3, 2, 1, 1, 1], Utils.diversity(a) )

    a = [3, -3, 4, 5, -4, 2, -4]
    assert_equal( [3, 2, 1, 1], Utils.diversity(a) { |item| item.abs } )
  end

  def test_percent
    assert_equal( 'N/A%', Utils.percent(1,0) )
    assert_equal( '10%', Utils.percent(1,10) )
  end
end

