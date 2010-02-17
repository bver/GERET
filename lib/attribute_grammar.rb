
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

    protected

    def pick_expansions( parent_token, genome )
      rules = super( parent_token, genome )

      allowed = []
      rules.each do |expansion|
#TODO: puts "checking #{parent_token.data} -> #{(expansion.map {|t| t.data}).join(' ')}"
        edges = @functions.node_expansion( parent_token, expansion ).map do |attr_fn|
          AttrEdge.create( parent_token, expansion, attr_fn )
        end

        # process all edges for the _valid attribute
        edges.concat( @edges.map {|e| AttrEdge.new( e.dependencies.clone, e.result.clone, e.func.clone )} ) #TODO: cleaner!
        new_attrs = Edges.reduce_batch( edges, @attributes )

        next if found_invalid? new_attrs 
        allowed << expansion
#TODO: puts "allowed."	
      end
      raise "AttrGrDepthFirst: all possible expansions semanantically restricted" if allowed.empty? #TODO: test
      
      allowed
    end

    def use_expansion( parent_token, alt )
      expansion = super( parent_token, alt )
      edges = @functions.node_expansion( parent_token, expansion ).map do |attr_fn|
        AttrEdge.create( parent_token, expansion, attr_fn )
      end

      # process the current edges first
      new_attrs1 = Edges.reduce_batch( edges, @attributes )
     
      @edges.concat edges
      @attributes.update new_attrs1

      # process older edges with joined_attributes       
      new_attrs2 = @edges.reduce_batch( @attributes )

      @attributes.update new_attrs2
     
#TODO: dump parent_token, expansion
     
      expansion 
    end

    def found_invalid? attrs
      attrs.each_pair do |key,attr|
        next unless key.attr_idx == AttrIndexValid
        return true if attr == false
      end
      false
    end

def node_dump node
 "#{node.token_id}/#{ObjectSpace._id2ref(node.token_id).data}[#{ObjectSpace._id2ref(node.token_id).depth}].#{@functions.attributes[node.attr_idx] }"
end

def dump( parent_token, extension )

  puts "#{parent_token.data} -> #{(extension.map {|t| t.data}).join(' ')}  // #{@used_length}"      #Functions.match_key(extension) 

  @attributes.each_pair do
    |k,v| puts "  #{node_dump k} = #{v}"
  end

  @edges.each do |e|
  
    print "  @ ["

    e.dependencies.each do|d| 
      print d.kind_of?( AttrKey ) ? "#{node_dump d}" : d.to_s ; print ',' 
    end

    puts "] => #{node_dump e.result} "

  end

end




  end

end


