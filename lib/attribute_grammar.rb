
require 'lib/mapper'
require 'lib/abnf_file'
require 'lib/semantic_functions'
require 'lib/semantic_edges'

module Semantic

  class AttributeGrammar < Abnf::File 
    def semantic= filename
      @semantic_functions = Functions.new( IO.read( filename ) )
    end

    attr_reader :semantic_functions
  end

  class AttrGrDepthFirst < Mapper::DepthFirst

    def initialize( grammar )
      super grammar

      @functions = grammar.semantic_functions
      @edges = Edges.new
      @attributes = {}
    end

    def pick_rule( parent_token, genome )
      loop do
        extension = super( parent_token, genome )
        return extension if semantic_core( parent_token, extension, @used_length  )
      end
    end

    def generate_rule( recurs, parent_token, genome )
      loop do
        extension = super( recurs, parent_token, genome )
        return extension if semantic_core( parent_token, extension, genome.size )
      end   
    end 

    protected

    def semantic_core( parent_token, extension, age )
      edges = @functions.node_expansion( parent_token, extension ).map do |attr_fn|
        AttrEdge.create( parent_token, extension, attr_fn, age )
      end

      # process the current edges first
      new_attrs1 = Edges.reduce_batch( edges, @attributes, age )
      return false if found_invalid? new_attrs1
      @edges.concat edges
      @attributes.update new_attrs1

      # process older edges with joined_attributes       
      new_attrs2 = @edges.reduce_batch( @attributes, age )
      if found_invalid? new_attrs2
        @edges.prune_newer age
        @attributes.delete_if { |key, attr| attr.age >= age }
        return false
      end
        
      # ok, no invalidating attribute found
      @attributes.update new_attrs2
      true
    end

    def found_invalid? attrs
      attrs.each_pair do |key,attr|
        next unless @functions.attributes[key.attr_idx] == 'valid'
        return true if attr.value == false
      end
      false
    end

  end

end


