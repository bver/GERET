
module Operator

  class MutationSimplify
    Pattern = Struct.new( :symbol, :alt_idx, :dir, :parent_arg )
    Subtree = Struct.new( :id, :dir, :parent_arg )
    Replacement = Struct.new( :pattern_idx )

    def initialize
      @rules = []
      @mapper_type = nil
    end

    attr_accessor :rules, :mapper_type

    def mutation( parent, track )
      track_reloc = reloc(track)     
      mutant = parent.clone
      @rules.each do |rule|
        ptm = match( track_reloc, rule.first )
        return replace( mutant, ptm, rule.first, rule.last, track_reloc ) unless ptm.empty?
      end
      mutant
    end

    def match( track_reloc, patterns )
      track_reloc.each_with_index do |node, index|
        next unless match_node?( node, patterns.first )
        ptx = match_patterns( track_reloc, patterns, index )
        return ptx unless ptx.empty?
      end
      []
    end

    def match_patterns( track_reloc, patterns, node_idx )
      ptx = [node_idx]
      stack = [node_idx]

      patterns[1...patterns.size].each do |pattern|
        found = track_reloc.find { |n| n.back == stack.last and n.loc_idx == pattern.parent_arg }
        return [] if found.nil?       

        if pattern.kind_of? Pattern
          return [] unless match_node?( found, pattern )
          node_idx = track_reloc.index( found )
          ptx << node_idx
        else # assuming Subtree
          children = [ found ]
          indices = []
          until children.empty?
            idx = track_reloc.index( children.pop )
            children.concat track_reloc.find_all { |n| n.back == idx }
            indices << idx
          end
          ptx << indices
        end

        case pattern.dir
        when -1
          stack.push node_idx
        when 0
        else
          pattern.dir.times { stack.pop }
        end

      end

      ptx
    end

    def replace( genome, ptm, patterns, replacement, track_reloc )
     root_node = track_reloc[ptm.first]
     res = genome[0 ... root_node.from].clone

     replacement.each do |idx|
       replace = ptm[idx]      
       node_idx = replace.kind_of?(Array) ? replace.first : replace
       node = track_reloc[ node_idx ]
       res.concat genome[node.from .. node.to]
     end

     res.concat genome[(root_node.to+1) ... genome.size] 
     res
    end
   
    def reloc track
      case @mapper_type     
      when 'DepthFirst'
        reloc_first track
      when 'DepthLocus'
        reloc_locus track
      when nil
        raise "MutationSimplify: mapper_type not selected"
      else
        raise "MutationSimplify: mapper_type not supported"
      end
    end

    protected

    def reloc_locus track
      rel = track.clone
      counts = {}

      rel.each do |node|
        count = counts[node.back] 
        if count.nil?
          counts[node.back] = [0]
        else
          counts[node.back] << count.size        
        end
      end

      rel.each do |node|
        node.loc_idx = counts[node.back][node.loc_idx]
        counts[node.back].delete node.loc_idx
      end

      rel
    end
    
    def reloc_first track
      rel = track.clone
      counts = {}
      counts.default = 0

      rel.each do |node|
        node.loc_idx = counts[node.back]
        counts[node.back] += 1
      end

      rel
    end

   
#    def find_node( pattern, current )
#      current.detect do |node| 
#        node.symbol == pattern.symbol and 
#        node.alt_idx == pattern.alt_idx and 
#        node.back == pattern.parent_idx and
#        node.loc_idx == pattern.parent_arg     
#      end
#    end

    def match_node?( node, pattern )
      node.symbol == pattern.symbol and node.alt_idx == pattern.alt_idx
    end

  end

end # Operator

