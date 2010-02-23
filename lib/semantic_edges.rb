
require 'lib/semantic_types'

module Semantic

  # Base structure of the particular semantic function.
  #   :dependencies .. array of the input arguments (an item is AttrKey OR the actual value of the attribute),
  #   :result .. AttrKey of the output's attribute,
  #   :func .. reference to the compiled proc.
  AttrEdgeStruct = Struct.new( 'AttrEdgeStruct', :dependencies, :result, :func )

  # The instance of the semantic function defining a value of the node.attribute
  class AttrEdge < AttrEdgeStruct
    # Return true if the AttrEdge is ready for execution (all argument values are available).
    def is_executable? 
      ( dependencies.detect { |d| d.class == AttrKey } ).nil?
    end

    # Execute the semanitic function.
    def exec_func
      # raise "Semantic::AttrEdge is_executable? check fails" unless is_executable?
      func.call( dependencies )
    end

    # Create the AttrEdge from parent_token, RuleAlt and the AttrFn description.
    def AttrEdge.create( parent_token, child_tokens, attr_fn )
      tokens = [ parent_token ].concat( child_tokens )

      dependencies = attr_fn.args.map do |ref|
        if ref.attr_idx == AttrIndexText 
          tokens[ ref.node_idx ].data 
        else
          AttrKey.new( tokens[ ref.node_idx ].object_id, ref.attr_idx )
        end
      end

      result = AttrKey.new( tokens[ attr_fn.target.node_idx ].object_id, attr_fn.target.attr_idx )

      return AttrEdge.new( dependencies, result, attr_fn.func ) 
    end

    # Given the { AttrKey => value } hash, replace items in :dependencies array if posible
    def substitute_deps attr_hash
      dependencies.map! do |arg|
        if arg.class == AttrKey
          attr = attr_hash.fetch( arg, nil )
          attr.nil? ? arg : attr
        else
          arg
        end
      end
    end

  end

  # This class holds AttrEdge edges of the semantic graph (ie. all pending semantic functions 
  # waiting for the arguments to be computed).
  class Edges < Array

    # Compute all internal AttrEdge edges given that { AttrKey => value } contains attribute values.
    # Return new { AttrKey => value } hash with computed results, remove computed internal edges.
    def reduce_batch( attr_hash )
      Edges.reduce_batch( self, attr_hash )
    end

    # Compute all AttrEdge edges given that { AttrKey => value } contains attribute values.
    # Return new { AttrKey => value } hash with computed results, remove computed edges.
    def Edges.reduce_batch( edges, attr_hash )
      
      edges.each { |e| e.substitute_deps( attr_hash ) }    

      new_hash = {}
      loop do

        removal = []
        edges.each do |e|

          e.substitute_deps( new_hash )
          next unless e.is_executable?

          new_hash[ e.result ] = e.exec_func 
          removal << e
        end
        
        break if removal.empty?
        removal.each { |e| edges.delete e }     

      end

      new_hash
    end

  end

end

