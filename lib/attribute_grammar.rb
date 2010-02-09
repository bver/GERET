
require 'lib/mapper'
require 'lib/semantic_functions'
require 'lib/semantic_edges'

module Semantic

  class AttrGrDepthFirst < Mapper::DepthFirst

    def initialize( grammar, semantic )
      super grammar

      @functions = Functions.new semantic
      @edges = Edges.new
      @attributes = {}
    end

    def pick_rule( parent_token, genome )
      loop do
        
        extension = super( parent_token, genome )
        
        edges = @functions.node_expansion( parent_token, extension ).map do |attr_fn|
          AttrEdge.create( parent_token, extension, attr_fn, @used_length )
        end

        # process the current edges first
        new_attrs1 = Edges.reduce_batch( edges, @attributes, @used_length )
        next if found_invalid? new_attrs1
        @edges.concat edges
        @attributes.update new_attrs1

        # process older edges with joined_attributes       
        new_attrs2 = @edges.reduce_batch( @attributes, @used_length )
        if found_invalid? new_attrs2
          @edges.prune_newer @used_length
          @attributes.delete_if {|key, attr| attr.age >= @used_length}
          next
        end
        
        # ok, no invalidating attribute found
        @attributes.update new_attrs2
        return extension 

      end
    end

    protected

    def found_invalid? attrs
      attrs.each_pair do |key,attr|
        next unless @functions.attributes[key.attr_idx] == 'valid'
        return true if attr.value == false
      end
      false
    end

  end

end


