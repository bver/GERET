
$LOAD_PATH << '.'

require 'test/unit'
require 'test/mock_rand'
require 'lib/attribute_grammar'
require 'lib/abnf_file'

class TC_AttributeGrammar < Test::Unit::TestCase

  def setup
    @grammar = Semantic::AttributeGrammar.new 'test/data/knapsack.abnf'
    @grammar.semantic = 'test/data/knapsack.yaml'   
  end

  def test_basic

    m = Semantic::AttrGrDepthFirst.new( @grammar )

    assert_equal( 0, m.attributes.size )
    assert_equal( 'i3i1i2', m.phenotype( [0, 1, 2, 1, 0, 0, 0] ) )
    assert_equal( 7, m.used_length )
    assert_equal( 14, m.attributes.size )   

    assert_equal( 'i3i1i2', m.phenotype( [1, 1, 2, 1, 2, 1, 0] ) )
    assert_equal( 7, m.used_length )
    assert_equal( 14, m.attributes.size )   # testing the attributes cleanup
  end

  def test_generate
    m = Semantic::AttrGrDepthFirst.new( @grammar )
    m.consume_trivial_codons = true

    r = MockRand.new [{1=>0},0, {2=>1},0, {3=>2},0, {2=>1},0, {2=>0},0, {1=>0},0, {1=>0},0 ]
    m.random = r   

    gen = [0, 1, 2, 1, 0, 0, 0]
    assert_equal( gen, m.generate_grow( 5 ) )
    assert_equal( 14, m.attributes.size )

    r = MockRand.new [{1=>0},0, {2=>1},0, {3=>2},0, {2=>1},0, {2=>0},0, {1=>0},0, {1=>0},0 ]
    m.random = r   
    assert_equal( gen, m.generate_grow( 5 ) )
    assert_equal( 14, m.attributes.size )   # testing the attributes cleanup  
  end

  def test_overrestricted
    grammar = Semantic::AttributeGrammar.new 'test/data/knapsack.abnf'
    grammar.semantic = 'test/data/knapsack2.yaml'   

    m = Semantic::AttrGrDepthFirst.new( grammar )
    m.consume_trivial_codons = true

    r = MockRand.new [{1=>0},0, {2=>1},0, {3=>2},0, {2=>1},0, {2=>0},0, {2=>1},0, {1=>0},0, {2=>1},0 ]
    m.random = r   

    exception = assert_raise( RuntimeError ) { m.generate_grow( 7 ) } # 5
    assert_equal( "AttrGrDepthFirst: all possible expansions semantically restricted", exception.message )
  end
 
end

