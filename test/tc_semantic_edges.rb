#!/usr/bin/ruby

require 'test/unit'
require 'lib/grammar'
require 'lib/semantic_edges'

include Semantic
include Mapper

class TC_SemanticEdges < Test::Unit::TestCase

  def test_is_executable
    edge = AttrEdge.new( [] )
    assert_equal( true, edge.is_executable? )
    edge = AttrEdge.new( [ 3, 'rr', 4.5, [] ] )
    assert_equal( true, edge.is_executable? )
    edge = AttrEdge.new( [ 3, 'rr', AttrKey.new(0,0), [] ] )
    assert_equal( false, edge.is_executable? )   
  end

  def test_exec
    p = proc {|_| (_.map {|x| x.to_s }).join ' ' }
    edge = AttrEdge.new( [ 3, 'rr', 4.5 ], nil, p )   
    assert_equal( '3 rr 4.5', edge.exec_func )
     
    edge.dependencies = ['foo','bar']
    assert_equal( 'foo bar', edge.exec_func )   

    # check is not needed?
    # edge.dependencies << AttrKey.new(0,0)
    # exception = assert_raise( RuntimeError ) { edge.exec_func }
    # assert_equal( "Semantic::AttrEdge is_executable? check fails", exception.message )
  end

  def test_tokens_to_keys # transform AttrRef->AttrKey using incoming tokens
    target = AttrRef.new( 2, 2 )
    args = [ AttrRef.new( 1, 0 ), AttrRef.new( 0, 3 ) ]
    function = proc { |_| _ }
    attr_fn = AttrFn.new( function, target, args )
    parent_token = Token.new( :symbol, 'expr' )
    child1 = Token.new( :literal, 'immediate_text' )
    child2 = Token.new( :symbol, 'x' )
    child_tokens = [ child1, child2 ]
    age = 42

    edge = AttrEdge.create( parent_token, child_tokens, attr_fn, age )
    
    assert( edge.kind_of? AttrEdge )
    assert_equal( 2, edge.dependencies.size )
    assert_equal( 'immediate_text', edge.dependencies.first ) # attr_idx = 0 is implicitly 'text'
    assert_equal( AttrKey.new( parent_token.object_id, 3 ), edge.dependencies.last )   
    assert_equal( AttrKey.new( child2.object_id, 2 ), edge.result )
    assert_equal( function.object_id, edge.func.object_id )
    assert_equal( age, edge.age )
  end

  def test_substitute_dependencies # by real attrs' values
    
    dependencies = [ AttrKey.new( 100, 5 ) ]
    dependencies << AttrKey.new( 300, 3 )
    dependencies << AttrKey.new( 200, 2 )   
    dependencies << 'foo'
    dependencies << AttrKey.new( 200, 1 )
    dependencies << AttrKey.new( 100, 5 )

    edge = AttrEdge.new( dependencies )

    attr_hash = { 
      AttrKey.new( 100, 5 ) => Attribute.new( 'bar' ), 
      AttrKey.new( 200, 1 ) => Attribute.new( 'baz' ) 
    }
    
    edge.substitute_deps( attr_hash )

    assert_equal( ['bar', AttrKey.new(300,3), AttrKey.new(200,2), 'foo', 'baz', 'bar' ], edge.dependencies )
  end

  def test_reduce_batch 
    # try execute whole edges enumerable, produce results, 
  
    p1 = proc {|_| (_.map {|x| x.to_s }).join ' ' }
    p2 = proc {|_| (_.map {|x| x.to_s }).join '.' }   
    edge1 = AttrEdge.new( [ 'a', AttrKey.new(404,3), 'c', 
                            AttrKey.new(303,3), AttrKey.new( 304, 3 ) ], 
                            AttrKey.new(300,3), p1 ) # ['a',?,'c','a 0.1 c','e' ]   
    edge2 = AttrEdge.new( [ 'a', AttrKey.new(301,3), AttrKey.new(302,3) ], AttrKey.new(303,3), p1 ) # 'a 0.1 c'    
    edge3 = AttrEdge.new( [ '0', '1' ], AttrKey.new(301,3), p2 ) # '0.1'   

    edges = Edges.new
    edges.concat [ edge1, edge2, edge3 ]

    attr_hash = { 
      AttrKey.new( 302, 3 ) => Attribute.new( 'c' ), 
      AttrKey.new( 302, 1 ) => Attribute.new( 'baz' ),
      AttrKey.new( 304, 3 ) => Attribute.new( 'e' )     
    }
 
    new_results_hash = edges.reduce_batch( attr_hash, 444 )

    assert_equal( { AttrKey.new(303,3)=>Attribute.new('a 0.1 c',444), 
                    AttrKey.new(301,3)=>Attribute.new('0.1',444) }, new_results_hash )
    assert_equal( 1, edges.size )
    assert_equal( AttrEdge, edges.first.class )
    assert_equal( ['a',AttrKey.new(404,3),'c','a 0.1 c','e' ], edges.first.dependencies )
    assert_equal( AttrKey.new(300,3), edges.first.result )
    assert_equal( p1, edges.first.func )
  end

  def test_prune_by_age
#    edges.prune_newer( age )
  end

end



