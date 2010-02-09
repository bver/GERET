#!/usr/bin/ruby

require 'test/unit'
require 'lib/attribute_grammar'
require 'lib/abnf_file'

class TC_AttributeGrammar < Test::Unit::TestCase

  def setup
    @grammar =  Abnf::File.new 'test/data/knapsack.abnf'
    @semantic = IO.read 'test/data/knapsack.yaml'   
  end

  def test_basic

    m = Semantic::AttrGrDepthFirst.new( @grammar, @semantic )

    assert_equal( 'i3i1i2', m.phenotype( [1, 1, 2, 1, 0, 0, 1] ) )
    assert_equal( 7, m.used_length )

    assert_equal( 'i3i1i2', m.phenotype( [1, 1, 2, 1, 2, 0, 0, 0, 2, 1] ) )
    assert_equal( 10, m.used_length )
   
  end


end

