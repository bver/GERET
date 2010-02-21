
require 'yaml'
require 'lib/semantic_types'

module Semantic

  class Functions < Hash

    # The '_' identifier is reserved and cannot be used as the attribute name or another variable name.
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

    attr_reader :attributes

    def node_expansion( symbol, expansion )
      node = fetch(symbol.data, nil)
      return [] if node.nil?
      batch = deep_copy( node.fetch( Functions.match_key(expansion), [] ) )
      return batch.concat deep_copy( node.fetch( '*', [] ) )
    end

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

    def Functions.extract_args text
      text.scan( /[\w\d]+\.[\w\d]+/ ).uniq
    end

    def Functions.replace_args( text_orig, args )
      text = text_orig.clone
      args.each_with_index { |a,i| text.gsub!( a, "_[#{i}]" ) }
      text
    end

    def Functions.make_proc text
      eval( "proc { |_| #{text} }" )
    end

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

    def render_attr ref
      "#{ ref.node_idx==0 ? 'p' : 'c'+(ref.node_idx-1).to_s }.#{ @attributes[ ref.attr_idx ] }"
    end

    protected

    def deep_copy funcs
      funcs.map { |f| AttrFn.new(f.func, f.target, f.args.clone, f.orig) } 
    end
   
  end

end


