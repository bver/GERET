
require 'lib/semantic_types'

module Semantic

  class AttrEdge < Struct.new( :dependencies, :result, :func, :age )
    
    def is_executable? 
      ( dependencies.detect { |d| d.class == AttrKey } ).nil?
    end

    def exec_func
      # raise "Semantic::AttrEdge is_executable? check fails" unless is_executable?
      func.call( dependencies )
    end

    def AttrEdge.create( parent_token, child_tokens, attr_fn, age )
      tokens = [ parent_token ].concat( child_tokens )

      dependencies = attr_fn.args.map do |ref|
        if ref.attr_idx == AttrIndexText 
          tokens[ ref.node_idx ].data          # attr_idx == 0 means attr.text 
        else
          AttrKey.new( tokens[ ref.node_idx ].object_id, ref.attr_idx )
        end
      end

      result = AttrKey.new( tokens[ attr_fn.target.node_idx ].object_id, attr_fn.target.attr_idx )

      return AttrEdge.new( dependencies, result, attr_fn.func, age ) 
    end

    def substitute_deps attr_hash
      dependencies.map! do |arg|
        if arg.class == AttrKey
          attr = attr_hash.fetch( arg, nil )
          attr.nil? ? arg : attr.value
        else
          arg
        end
      end
    end

  end

  class Edges < Array

    def reduce_batch( attr_hash, age )
      Edges.reduce_batch( self, attr_hash, age )
    end

    def Edges.reduce_batch( edges, attr_hash, age )
      
      edges.each { |e| e.substitute_deps( attr_hash ) }    

      new_hash = {}
      loop do

        removal = []
        edges.each do |e|

          e.substitute_deps( new_hash )
          next unless e.is_executable?

          new_hash[ e.result ] = Attribute.new( e.exec_func, age )
          removal << e
        end
        
        break if removal.empty?
        removal.each { |e| edges.delete e }     

      end

      new_hash
    end

    def prune_newer age
      delete_if { |edge| edge.age >= age }
    end

  end

end

