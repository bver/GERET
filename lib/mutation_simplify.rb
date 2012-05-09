
module Operator

  class MutationSimplify
    Expansion = Struct.new( :symbol, :alt_idx, :dir, :parent_arg )
    Subtree = Struct.new( :dir, :parent_arg )
    RuleCase = Struct.new( :match, :outcome, :equals  )

    def initialize grammar
      @grammar = grammar
      @rules = []
      @mapper_type = nil

      @grammar_texts = {}
      @grammar_texts2 = {}
      @grammar.each_pair do |symbol, alt| 
        rule = {}
        rule2 = {}       

        (0...alt.size).each do |i|
          rule[ alt_idx2text( symbol, i ) ] = i
          rule2[ alt2text( symbol, i ) ] = i         
        end

        @grammar_texts[symbol] = rule
        @grammar_texts2[symbol] = rule2       
      end
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
        ptm = match_patterns( track_reloc, patterns, index )
        return ptm unless ptm.empty?
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
     args = exp_args( track_reloc, patterns, ptm )
     
     root_node = track_reloc[ptm.first]
     res = genome[0 ... root_node.from].clone

     replacement.each do |idx|
       if idx.kind_of? Expansion
         res << 0 if @mapper_type == 'DepthLocus' # TODO: different Codon types?
         if idx.alt_idx.respond_to? 'call'
           out = idx.alt_idx.call args
           return genome.clone if out.nil?  
           res << text2alt_idx( idx.symbol, out )
         else 
           res << idx.alt_idx
         end
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

    def exp_args( track_reloc, matching, ptm )
      res = []
      ptm.each_with_index do |node_idx,patt_idx|
        patt = matching[patt_idx]
        next unless patt.respond_to? 'alt_idx'
        next unless patt.alt_idx.nil? 
        res << alt_idx2text( patt.symbol, track_reloc[node_idx].alt_idx )
      end
      res
    end

    def alt_idx2text( symbol, alt_idx )
      (@grammar[symbol][alt_idx].map {|t| t.type == :symbol ? "<#{t.data}>" : t.data }).join     
    end

    def text2alt_idx( symbol, text )
      found = @grammar_texts[symbol]
      raise "MutationSimplify: altidx for symbol '#{symbol}' not found" if found.nil?
      res = found[text]
      raise "MutationSimplify: altidx for RuleAlt '#{text}' not found" if res.nil?
      res
    end

    # TODO: DRY
    def alt2text( symbol, alt_idx )
      (@grammar[symbol][alt_idx].map {|t| t.type == :symbol ? t.data : %Q["#{t.data}"] }).join(' ')
    end

    # TODO: DRY
    def text2alt( symbol, text )
      found = @grammar_texts2[symbol]
      raise "MutationSimplify: altidx for symbol '#{symbol}' not found" if found.nil?
      res = found[text]
      raise "MutationSimplify: altidx for RuleAlt '#{text}' not found" if res.nil?
      res
    end

    def parse_rules input
      rules = []
      input.each do |rule_case|
        patterns, refs, uses = parse_pattern rule_case['pattern']
        parse_depths( patterns, refs, uses )
        lambdas = rule_case.has_key?('lambdas') ? parse_lambdas( rule_case['lambdas'], patterns, refs ) : []
        replacement = parse_replacement( rule_case['replacement'], refs, lambdas )
        rules << RuleCase.new(patterns,replacement,parse_equals(refs))
      end
      rules
    end

    def parse_pattern texts
      patterns = []
      refs = []
      uses = [] 

      texts.each_with_index do |text,index|
        symb_dot,rule = text.split('=')
        symb_dot.strip!
        symb,dot = symb_dot.split('.')
        raise "MutationSimplify: '#{symb_dot}' must follow symbol.var syntax" if dot.nil?

        if rule.nil?
          # Subtree 
          patterns << Subtree.new()
          uses << []
        else
          # Expansion
          raise  "MutationSimplify: '#{symb_dot}' is defined more times" unless refs.index(symb_dot).nil?
          uses << rule.scan(/\w+\.\w+/)
          rule = rule.strip.gsub(/\.\w+/,'')
          alt_idx = (rule == '?') ? nil : text2alt( symb, rule )
          patterns << Expansion.new( symb, alt_idx )        
        end
        refs << symb_dot
       
      end
      
      return [patterns, refs, uses] 
    end

    def parse_depths( patterns, refs, uses )
      stack = [ DepthStack.new( [refs.first], 0, 0 ) ]

      patterns.each_with_index do |pattern, index|
        raise "MutationSimplify: parsing error" if stack.empty?
        current_symb = stack.last.symbols.shift
        raise  "MutationSimplify: wrong order: required '#{refs[index]}', declared '#{current_symb}'" if current_symb != refs[index] 
        current_depth = stack.last.depth
        pattern.parent_arg = stack.last.loc
        stack.last.loc += 1

        stack.pop if stack.last.symbols.empty?

        expansions = uses[index].clone
        stack <<  DepthStack.new( expansions, current_depth-1, 0 ) unless expansions.empty?

        pattern.dir = stack.empty? ? -current_depth : stack.last.depth - current_depth
      end
      raise "MutationSimplify: some symbols undefined" unless stack.empty?
    end

    def parse_lambdas( texts, patterns, refs )
      lambdas = {}
      var_idxs = []
      patterns.each_with_index { |p,i| var_idxs << i if p.alt_idx.nil? }     

      texts.each_pair do |key,value|
        text = "lambda do |a|\n#{value.clone}\nend"
        var_idxs.each_with_index { |v,i| text.gsub!( refs[v], "a[#{i}]" ) }
        lambdas[key] = eval(text)
      end

      lambdas
    end

    def parse_replacement( texts, refs, lambdas )
      replacement = []

      texts.each do |line|
        idx = refs.index line.strip
        if idx.nil?
          symb,rule = line.split('=')
          raise "MutationSimplify: replacement '#{line}' unknown" if rule.nil?
          symb.strip!
          replacement << Expansion.new( symb, text2alt( symb, rule.strip ) )         
        else
          replacement << idx
        end
      end

      replacement
    end

    protected

    DepthStack = Struct.new( :symbols, :depth, :loc )

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
      node.symbol == pattern.symbol and ( pattern.alt_idx.nil? or node.alt_idx == pattern.alt_idx )
    end

  end

end # Operator

