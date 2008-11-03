#!/usr/bin/ruby

require 'test/unit'
require 'lib/mapping'

class TC_Mapping < Test::Unit::TestCase

  def setup
  end

  def test_defaults_and_set
    m = Mapping.new
    assert_equal( :rule, m.codon_style )
    assert_equal( false, m.bucket_rule )   
    assert_equal( 255, m.max_rule )
    assert_equal( 255, m.max_locus )   
    assert_equal( 10, m.max_wrappings )
    assert_equal( :fail, m.overrun )

    m.codon_style = :rule_locus
    m.bucket_rule = true
    m.max_rule = 127
    m.max_locus = 63
    m.max_wrappings = 20
    m.overrun = :fading_0
  
    assert_equal( :rule_locus, m.codon_style )
    assert_equal( true, m.bucket_rule )   
    assert_equal( 127, m.max_rule )
    assert_equal( 63, m.max_locus )   
    assert_equal( 20, m.max_wrappings )
    assert_equal( :fading_0, m.overrun )
  end

  def test_param_ctor
    m = Mapping.new( :rule_locus, false, 30, 15, 55, :fading_0 )
    assert_equal( :rule_locus, m.codon_style )
    assert_equal( false, m.bucket_rule )   
    assert_equal( 30, m.max_rule )
    assert_equal( 15, m.max_locus )   
    assert_equal( 55, m.max_wrappings )
    assert_equal( :fading_0, m.overrun )
  end

  def test_param_ctor_half
    m = Mapping.new( :rule_locus, false, 30 )
    assert_equal( :rule_locus, m.codon_style )
    assert_equal( false, m.bucket_rule )   
    assert_equal( 30, m.max_rule )
    assert_equal( 255, m.max_locus )   
    assert_equal( 10, m.max_wrappings )
    assert_equal( :fail, m.overrun )
  end
 
end
