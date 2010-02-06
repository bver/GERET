
require 'lib/semantic_types'

module Semantic

  class AttrEdge < Struct.new( :dependencies, :result, :func, :age )
    
    def is_executable? 
      ( dependencies.detect { |d| d.kind_of? AttrKey } ).nil?
    end

    def exec_func
      # raise "Semantic::AttrEdge is_executable? check fails" unless is_executable?
      func.call( dependencies )
    end

    def AttrEdge.create( parent_token, child_tokens, attr_fn )

      tokens = [ parent_token ].concat( child_tokens )

      dependencies = attr_fn.args.map do |ref|
        if ref.attr_idx == 0 
          tokens[ ref.node_idx ].data          # attr_idx == 0 means attr.text 
        else
          AttrKey.new( tokens[ ref.node_idx ].object_id, ref.attr_idx )
        end
      end

      result = AttrKey.new( tokens[ attr_fn.target.node_idx ].object_id, attr_fn.target.attr_idx )

      return AttrEdge.new( dependencies, result, attr_fn.func ) 
      
    end

  end

  class Edges < Array
  end

end

