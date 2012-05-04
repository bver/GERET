
module Operator

  class MutationSimplify
    Pattern = Struct.new( :symbol, :alt_idx, :parent_idx, :parent_arg )
    Replacement = Struct.new( :patern_idx, :loc_idx )

    def initialize
      @rules = []
      @mapper_type = nil
    end

    attr_accessor :rules, :mapper_type

    def mutation( parent, track )
      mutant = parent.clone
      @rules.each do |rule|
        current = match( track, rule.first )
        return replace( mutant, current, rule.first, rule.last ) unless current.empty?
      end
      mutant
    end

    def match( track, patterns )
      track.each_with_index do |node, index|
        next unless match_node?( node, patterns.first )
        current = []
        track.each { |n| current.push(n.clone) if node.from<=n.from and n.to<=node.to }
        current.first.back = nil 
        current = reloc(current)         
        current.each { |n| n.back -= index unless n.back.nil? }
        rejected = patterns.reject { |p| not find_node(p,current).nil? }
        return current if rejected.empty?
      end
      []
    end

    def replace( genome, current, patterns, replacement )
     res = genome[0 ... current.first.from].clone
     replacement.each do |replace|
       node = find_node( patterns[replace.patern_idx], current )
       node_idx = current.index(node)
       keep = current.find {|c| c.back == node_idx and c.loc_idx == replace.loc_idx }
       res.concat genome[keep.from .. keep.to]
     end
     res.concat genome[(current.first.to+1) ... genome.size] 
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
    end
    
    def reloc_first track
      # TODO optimize O(n^2)
      rel = track.clone
      track.each_with_index do |node,index|
        idx = 0 
        rel.each do |n| 
          if n.back == index
            n.loc_idx = idx
            idx += 1
          end
        end
      end
      rel
    end

   
    def find_node( pattern, current )
      current.detect do |node| 
        node.symbol == pattern.symbol and 
        node.alt_idx == pattern.alt_idx and 
        node.back == pattern.parent_idx and
        node.loc_idx == pattern.parent_arg     
      end
    end

    def match_node?( node, pattern )
      node.symbol == pattern.symbol and node.alt_idx == pattern.alt_idx
    end

  end

end # Operator

