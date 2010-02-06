#!/usr/bin/ruby

require 'test/unit'
require 'lib/semantic_functions'

include Semantic

class TC_SemanticEdges < Test::Unit::TestCase

  def test_try_execute
    # edge.is_executable?
    # edge.exec
  end

  def test_tokens_to_keys # transform AttrRef->AttrKey using incoming tokens
    #edge = Edges.create_edge( parent_token, child_tokens, attr_fn )
  end

  def test_substitute_dependencies # by real attrs' values
    #edge.substitute_deps( attr_hash )
  end

  def test_process_epoch # gluing together: try execute whole batch, store results, fill pending's deps, store residual edges
  end

end



