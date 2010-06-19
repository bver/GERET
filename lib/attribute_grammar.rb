
require 'lib/mapper'
require 'lib/abnf_file'
require 'lib/semantic_functions'
require 'lib/semantic_edges'

module Semantic

  # The semantically extended Abnf::File. 
  #
  # This class adds the semantic attributes and semantic functions to the syntactic description of the grammar.
  # The semantic functions for context free grammars are described in:
  # http://cms.dc.uba.ar/materias/tl/2009/c2/practicas/Knuth-1968-SemanticsCFL.pdf
  #
  # Semantic functions are added to the tree (triggered) by the expansion of a nonterminal node.
  # Attributes and functions are defined in the YAML file (see AttributeGrammar#semantic= ).
  #
  class AttributeGrammar < Abnf::File 

    # Load the semantic file. For the description see Functions#initialize
    def semantic= filename
      @semantic_functions = Functions.new( IO.read( filename ) )
    end

    # The instance of the Function class (all parsed semantic functions).
    attr_reader :semantic_functions
  end

  # This mapper class implements the _modified_ version of the attribute grammar described in:
  # http://www.cs.bham.ac.uk/~wbl/biblio/gecco2004/WGEW003.pdf and
  # http://ncra.ucd.ie/downloads/pub/thesisExtGEwithAGs-CRC.pdf 
  #
  # If there is the boolean p._valid attribute defined for the nonterminal symbol expansion, 
  # the expansion is considered only if the value of such attribute is 'true'.
  # 
  # The implementation differs from the original thesis in this aspect: 
  # There is no "rollback phase" of semantic attributes processing when the invalid node 
  # expansion is reached (ie node._valid==false). Invalid expansions are simply ignored beforehand, 
  # no codons are wasted (in another words there are no introns due to the semantic restrictions 
  # present in the genotype string.
  #
  # See the AttributeGrammar class for detailed description of the semantic YAML file.
  # See the Mapper::DepthFirst class for detailed description of the mapper behavior.
  #
  class AttrGrDepthFirst < Mapper::DepthFirst

    # See Mapper::DepthFirst#new
    def initialize( grammar )
      super grammar

      @functions = grammar.semantic_functions
      clear
    end

    # Semantic attributes hash. It maps AttrKey identification to the attribute values.
    # Mainly for deugging and logging purposes.
    attr_reader :attributes

    # See Mapper::DepthFirst#phenotype 
    def phenotype genome
      clear
      super( genome )
    end

    # See Mapper::DepthFirst#generate
    def generate( recursivity, required_depth )   
      clear
      super( recursivity, required_depth )     
    end

    protected

    def clear
      @edges = Edges.new
      @attributes = {}
    end

    def pick_expansions( parent_token, genome )
      rules = super( parent_token, genome )

      allowed = []
      rules.each do |expansion|
        edges = @functions.node_expansion( parent_token, expansion ).map do |attr_fn|
          AttrEdge.create( parent_token, expansion, attr_fn )
        end

        # process all edges for the _valid attribute
        new_attrs = Edges.reduce_batch( edges, @attributes )

        next if found_invalid? new_attrs

        allowed << expansion
      end
      raise "AttrGrDepthFirst: all possible expansions semantically restricted" if allowed.empty?
      
      allowed
    end

    def filter_expansions_by_depth( rule, allowed_depth )
      rule     
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
     
      expansion 
    end

    def found_invalid? attrs 
      attrs.each_pair do |key,attr|
        next unless key.attr_idx == AttrIndexValid
        return true if attr == false
      end
      false
    end

  end

end


