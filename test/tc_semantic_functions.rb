#!/usr/bin/ruby

require 'test/unit'
require 'lib/grammar'
require 'lib/semantic_functions'

include Semantic
include Mapper

class TC_SemanticFunctions < Test::Unit::TestCase

  def test_match
    rulealt = RuleAlt.new( [ 
                    Token.new( :literal, '(' ), 
                    Token.new( :symbol, 'expr' ),
                    Token.new( :symbol, 'op' ),                  
                    Token.new( :symbol, 'expr' ),                   
                    Token.new( :literal, ')' ) 
                  ] )
    assert_equal( '"" expr op expr ""', Functions.match_key( rulealt ) )
  end

  def test_wrong_type
    rulealt = RuleAlt.new( [ Token.new( :wrong, '' ) ] )
    exception = assert_raise( RuntimeError ) { Functions.match_key( rulealt ) }
    assert_equal( "Semantic::Functions wrong token type", exception.message )
  end

  def test_attref
    sf = Functions.new
    assert_equal( ['text'], sf.attributes ) 
    assert_equal( AttrRef.new( 2, 1 ), sf.new_attr_ref( 'c1.ids' ) )
    assert_equal( ['text', 'ids'], sf.attributes )                 

    assert_equal( AttrRef.new( 2, 0 ), sf.new_attr_ref( 'c1.text' ) )  
    assert_equal( ['text', 'ids'], sf.attributes )                                 

    assert_equal( AttrRef.new( 0, 2 ), sf.new_attr_ref( 'p.fn' ) )
    assert_equal( ['text', 'ids', 'fn'], sf.attributes )                           

    assert_equal( AttrRef.new( 1, 1 ), sf.new_attr_ref( 'c0.ids' ) )   
    assert_equal( ['text', 'ids', 'fn'], sf.attributes )                              

    assert_equal( 'c1.ids', sf.render_attr( AttrRef.new( 2, 1 ) ) )   
    assert_equal( 'p.fn', sf.render_attr( AttrRef.new( 0, 2 ) ) )   
    assert_equal( 'c0.text', sf.render_attr( AttrRef.new( 1, 0 ) ) )   
    assert_equal( 'c5.ids', sf.render_attr( AttrRef.new( 6, 1 ) ) )       
  end

  def test_wrong_attr
    sf = Functions.new
    exception = assert_raise( RuntimeError ) { sf.new_attr_ref( 'wr0ng' ) }
    assert_equal( "Semantic::Functions wrong node/attribute 'wr0ng'", exception.message )
    exception = assert_raise( RuntimeError ) { sf.new_attr_ref( 'x.text' ) }
    assert_equal( "Semantic::Functions wrong node 'x.text'", exception.message )
    exception = assert_raise( RuntimeError ) { sf.new_attr_ref( 'c.text' ) }
    assert_equal( "Semantic::Functions wrong node 'c.text'", exception.message )
  end

  def test_xtract_args
    text = " (c0.id=='') ? p.ids.include? c1.fnid : c0.id"
    args = ['c0.id','p.ids','c1.fnid'] 
    assert_equal( args, Functions.extract_args(text) )
  
    assert_equal( " (_[0]=='') ? _[1].include? _[2] : _[0]", Functions.replace_args(text,args)  )
    assert_equal( " (c0.id=='') ? p.ids.include? c1.fnid : c0.id", text ) # do not change original
  end

  def test_proc
    # p.valid : c0.fnid != p.context && p.ids.include? c0.fnid 
    text = "_[0] != _[1] && _[2].include?( _[0] )"
    p = Functions.make_proc text 
    assert_equal( true, p.call([ 'fn3', 'main', ['fn1','fn3','fn4'] ]) )
    assert_equal( false, p.call([ 'fn3', 'fn3', ['fn1','fn3','fn4'] ]) )   
    assert_equal( false, p.call([ 'fn3', 'main', ['fn1','fn4'] ]) )  
    assert_equal( true, p.call([ 'fn1', 'fn4', ['fn1','fn4'] ]) )     
  end

  def test_parse
    sf = Functions.new( IO.read('test/data/semantic.yaml') )

    assert( sf.kind_of? Hash )
    assert_equal( [ 'node1', 'start' ], sf.keys.sort )
    assert( sf['node1'].kind_of? Hash )

    assert_equal( [ 'text', 'id', 'x', 'y' ], sf.attributes )  # text is implicit

    assert_equal( ['fn'], sf['start'].keys )
    rule0 = sf['start']['fn']
    assert( rule0.kind_of? Array )
    assert_equal( 1, rule0.size )   
    assert_equal( 1, rule0.first.target.node_idx ) # c0=1
    assert_equal( 1, rule0.first.target.attr_idx ) # id=1
    assert_equal( [], rule0.first.args )
    assert_equal( 1, rule0.first.func.arity )
    assert_equal( 'text', rule0.first.func.call([]) )
    assert_equal( "'text'", rule0.first.orig )

    assert_equal( ['*', 'node2 ""'], sf['node1'].keys.sort )
    rule1 = sf['node1']['node2 ""']
    assert_equal( 2, rule1.size )
    assert_equal( AttrRef.new( 0, 1 ), rule1.first.target ) # p=0, id=1
    assert_equal( [ AttrRef.new( 1, 2 ) ], rule1.first.args ) # c0=1, x=2
    assert_equal( 1, rule1.first.func.arity )
    assert_equal( "c0.x + 'x'", rule1.first.orig )
    assert_equal( 'foox', rule1.first.func.call(['foo']) )   
    assert_equal( AttrRef.new( 1, 2 ), rule1.last.target ) # c0.x
    assert_equal( AttrRef.new( 0, 1 ), rule1.last.args[0] ) # p.id
    assert_equal( AttrRef.new( 2, 0 ), rule1.last.args[1] ) # c1.text
    assert_equal( AttrRef.new( 1, 3 ), rule1.last.args[2] ) # c0.y   
    assert_equal( 1, rule1.last.func.arity )
    assert_equal( 'foobarbaz', rule1.last.func.call(['foo','bar','baz']) )   
    assert_equal( "p.id + c1.text + c0.y", rule1.last.orig )   
 
    rule2 = sf['node1']['*']
    assert_equal( 1, rule2.size )
    assert_equal( AttrRef.new( 0, 3 ), rule2.first.target ) # p.y
    assert_equal( [ AttrRef.new( 1, 3 ) ], rule2.first.args ) # c0.y
    assert_equal( 1, rule2.first.func.arity )
    assert_equal( 'xyz', rule2.first.func.call(['xyz']) )   
    assert_equal( "c0.y", rule2.last.orig )   
  end

  def test_expansion
    sf = Functions.new( IO.read('test/data/semantic.yaml') )
    
    symbol = Token.new( :symbol, 'node1' )

    expansion = [ Token.new( :symbol, 'UNKNOWN_NODE' ) ]
    batch = sf.node_expansion( symbol, expansion ) 
    assert_equal( 1, batch.size ) # defaulting to *
    assert_equal( "c0.y", batch.first.orig )
 
# there is no need for deep copies (they only slow down the process)    
#    batch.first.orig = 'shallow copy?'
#    assert_equal( "c0.y", sf['node1']['*'].first.orig ) # deep copy 
#    assert_equal( [ AttrRef.new( 1, 3 ) ], sf['node1']['*'].first.args )
#    batch.first.args = [ AttrRef.new( 0, 0 ) ]
#    assert_equal( [ AttrRef.new( 1, 3 ) ], sf['node1']['*'].first.args ) # deep copy

    expansion = [ Token.new( :symbol, 'node2' ), Token.new( :literal, 'whatever' ) ]
    batch = sf.node_expansion( symbol, expansion ) 
    assert_equal( 3, batch.size ) # both 'node2 ""' and '*'
    assert_equal( "c0.x + 'x'", batch[0].orig )
    assert_equal( "p.id + c1.text + c0.y", batch[1].orig )   
    assert_equal( "c0.y", batch[2].orig )

    symbol = Token.new( :symbol, 'UNKNOWN' )   
    batch = sf.node_expansion( symbol, expansion ) 
    assert_equal( 0, batch.size )
  end

end



