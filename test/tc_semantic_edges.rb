#!/usr/bin/ruby

require 'test/unit'
require 'lib/semantic_edges'

include Semantic

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

    # check is not necesarry?
    # edge.dependencies << AttrKey.new(0,0)
    # exception = assert_raise( RuntimeError ) { edge.exec_func }
    # assert_equal( "Semantic::AttrEdge is_executable? check fails", exception.message )
  end

  def test_tokens_to_keys # transform AttrRef->AttrKey using incoming tokens
    # edge = AttrEdge.create( parent_token, child_tokens, attr_fn )
  end

  def test_substitute_dependencies # by real attrs' values
    # edge.substitute_deps( attr_hash )
  end

  def test_reduce_batch 
    # try execute whole batch, produce results, 
    # new_results_hash = Edges.reduce_batch( batch, attr_hash )
  end

  def test_reduce_pending
    # new_results_hash = edges.reduce( attr_hash )
  end

  def test_prune_by_age
#    edges.prune_newer( age )
  end

end



