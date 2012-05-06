
module Operator

  class MutationSimplify
    Expansion = Struct.new( :symbol, :alt_idx, :dir, :parent_arg )
    Subtree = Struct.new( :id, :dir, :parent_arg )
    RuleCase = Struct.new( :match, :outcome, :equals  )

    def initialize
      @rules = []
      @mapper_type = nil
    end

    attr_accessor :rules, :mapper_type

    def mutation( parent, track )
      track_reloc = reloc(track)     
      mutant = parent.clone
      @rules.each do |rule|
        ptm = match( track_reloc, rule.match )
        next if ptm.empty?
        next unless check_equals( track_reloc, rule.equals, ptm )
        return replace( mutant, ptm, rule.match, rule.outcome, track_reloc )
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

        return [] if pattern.kind_of?(Expansion) and not match_node?( found, pattern )
        
        node_idx = track_reloc.index( found )
        ptx << node_idx

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
       if idx.kind_of? Expansion
         res << 0 if @mapper_type == 'DepthLocus' # TODO: different Codon types?
         res << idx.alt_idx
       else
         node = track_reloc[ ptm[idx] ]
         res.concat genome[node.from .. node.to]
       end
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

    def nodes_equal( track_reloc, node1_idx, node2_idx )
      tree1 = load_tree( track_reloc, node1_idx )
      tree2 = load_tree( track_reloc, node2_idx )
      return false if tree1.size != tree2.size
      tree1.each_with_index do |idx1,i|
        return false unless match_node?( track_reloc[idx1], track_reloc[tree2[i]] )
      end
      true
    end

    protected

    def check_equals( track_reloc, equals, ptm )
      equals.each do |pair|
        return false unless nodes_equal( track_reloc, ptm[pair.first], ptm[pair.last] )
      end
      true
    end

    def load_tree( track_reloc, idx )
      indices = [ idx ]
      result = []
      until indices.empty?
        parent_idx = indices.pop
        result << parent_idx
        children = track_reloc.find_all { |n| n.back == parent_idx }
        children.sort! { |a,b| a.loc_idx <=> b.loc_idx }
        indices.concat( children.map { |c| track_reloc.index c } )
      end
      result
    end

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

    def match_node?( node, pattern )
      node.symbol == pattern.symbol and node.alt_idx == pattern.alt_idx
    end

  end

end # Operator

