
require 'yaml'
require 'lib/semantic_types'

module Semantic

  # Parsing and storing of the syntactic functions.
  # The Functions class subclasses the Hash class. It maps nonterminal symbols to its expansion hashes of the semantic functions:
  #
  #   { 
  #     "symbol1" => { "expansion1_1"=>[ AttrFn, AttrFn ... ], "expansion1_2"=>[ AttrFn, AttrFn ... ], ... },
  #     "symbol2" => { "expansion2_1"=>[ AttrFn, AttrFn ... ], "expansion2_2"=>[ AttrFn, AttrFn ... ], ... },     
  #     ...
  #   } 
  #
  class Functions < Hash

    # Load the semantic file. The file has to follow this form:
    #
    #   symbol1:
    #     expansion1:
    #       result1_1 : function1_1
    #       result1_2 : function1_2
    #       ...
    #       result1_N1 : function1_N1
    #     expansion2:
    #       result2_1 : function2_1
    #       ...
    #       result2_N2 : function2_N2
    #     ...
    #     expansionM:
    #       ...
    #    symbol2:
    #    ...
    #    symbolP:
    #      ...
    #
    # where:
    #    - symbol ... a nonterminal symbol defined by the ABNF grammar (see Mapper::Grammar)
    #    - expansion ... the expansion of the symbol defined by the grammar. 
    #                  All terminal symbols are matched by the '$' character. 
    #                  For instance, the ABNF rule:
    #
    #                  if-statement = "if(" condition ") {" block "} else {" block "}"
    #
    #                  is represented by:
    #
    #                  if-statement:
    #                    $ condition $ block $ block $:
    #
    #                  There is another special character '*' which matches all expansions.
    #    - result ... the semantic attribute of some symbol defined by the semantic function.
    #               It has the form:
    #                 node.attribute
    #               where attribute is the identifier of the attribute and node is either
    #               p (parent node) or ci (child node, i is the index of the child beginning from 0).
    #
    #               There are reserved attribute identifiers:
    #               _text  .. represents the text of the terminal symbol or the symbol identifier
    #                         of the nonterminal symbol
    #               _valid .. the boolean attribute which restricts the usage of the expansion 
    #                         (see AttrGrDepthFirst class for details)
    #    - function ... the semantic function using node.attribute arguments, using the Ruby syntax.
    #
    #
    # Notes: The '_' identifier is reserved and cannot be used as the attribute name or another variable name.
    # If the attribute's 'nil' value means 'not defined'. Do not use 'nil' as a result of a semantic function.
    #
    def initialize semantic=nil

      super()

      @attributes = AttrIndices.clone     

      # default ctor
      return if semantic.nil?

      # parsing ctor
      YAML::load( semantic ).each_pair do |symbol,rules|

        newrules = {}
        rules.each_pair do |expansion,funcs|

          batch = []
          funcs.each_pair do |dest,body|

            target = new_attr_ref dest
            args = Functions.extract_args( body )
            inputs = args.map { |arg| new_attr_ref arg }
            fn = Functions.make_proc( Functions.replace_args(body,args) )

            batch << AttrFn.new( fn, target, inputs, body )
          end

          newrules[expansion] = batch
        end

        store( symbol, newrules ) 
      end

    end

    # Attribute identifier array. It contains all attribute identifiers appearing on both 
    # the left and right sides of semantic fuctions. For example:
    #
    #   [ '_text', '_valid', 'cont', 'def', 'span' ]
    #
    # Note that reserved identifiers beginning with '_' are always present.
    #
    attr_reader :attributes


    # Convert the Mapper::RuleAlt into the representing string (the expansion key).
    def Functions.match_key rulealt 
      result = rulealt.map do |token|
        case token.type
        when :literal
          '$'
        when :symbol
          token.data
        else
          raise 'Semantic::Functions wrong token type'
        end
      end

      result.join ' '
    end

    # Extract all arguments from the body of the semantic function.
    def Functions.extract_args text
      text.scan( /[\w\d]+\.[\w\d]+/ ).uniq
    end

    # Replace argument identifiers in the source of the semantic function by the _[i] notation.
    def Functions.replace_args( text_orig, args )
      text = text_orig.clone
      args.each_with_index { |a,i| text.gsub!( a, "_[#{i}]" ) }
      text
    end

    # Compile the semantic function previously processed by the extract_args and replace_args.
    def Functions.make_proc text
      eval( "proc { |_| #{text} }" )
    end

    # Search for the appropriate semantic functions by the particular nonterminal symbol and the RuleAlt expansion.
    def node_expansion( symbol, expansion )
      node = fetch(symbol.data, nil)
      return [] if node.nil?
      batch = deep_copy( node.fetch( Functions.match_key(expansion), [] ) )
      return batch.concat deep_copy( node.fetch( '*', [] ) )
    end
   
    # Convert the textual representation of the attribute to the AttrRef (the inversion is done by the render_attr method). 
    # For instance: 'c1._text' -> AttrRef.new( 2, 0 ).
    # Note it modifies @attributes if given a new attribute identifier.
    def new_attr_ref text
      all,node,attr = /^([^.]*)\.([^.].*)$/.match( text ).to_a
      raise "Semantic::Functions wrong node/attribute '#{text}'" if all.nil?

      idx = @attributes.index attr
      if idx.nil?
        idx = @attributes.size       
        @attributes.push attr
      end

      return AttrRef.new( 0, idx ) if node == 'p' 

      raise "Semantic::Functions wrong node '#{text}'" unless node.size > 1 and /^c/ =~ node  
      return AttrRef.new( node[1,node.size-1].to_i+1, idx ) 
    end

    # Convert the AttrRef to the textual representation of the attribute (the inversion is done by the new_attr_ref).
    # For example: AttrRef.new( 0, 1 ) -> 'p._valid'.
    def render_attr ref
      "#{ ref.node_idx==0 ? 'p' : 'c'+(ref.node_idx-1).to_s }.#{ @attributes[ ref.attr_idx ] }"
    end

    protected

    def deep_copy funcs
      funcs.map { |f| AttrFn.new(f.func, f.target, f.args.clone, f.orig) } 
    end
   
  end

end


