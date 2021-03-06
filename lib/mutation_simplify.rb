
require 'yaml'

module Operator

  # Algebraic simplification inspired by:
  # http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.96.7953
  #
  # MutationSimplify checks if the genotype-phenotype mapping tree contains the specific patterns and if it finds one it replaces 
  # the according part of the genotype with a new part folowing certain rules. The motivation is that the phenotype
  # which represents the algebraic expression can be often simplified by algebraic rules eg.:
  #
  #  A * 1 -> A
  #  A * B + A * C -> A * (B + C)
  #  sin(0) -> 0
  #  ...
  #  etc. 
  #
  # This process incorporates a domain knowledge into the evolutionary process an may help to lower the average
  # complexity of phenotypes. It can be seen as the kind of mutation so it is compatible with the mutation operator interface.
  # The description of the patterns and replacements is stored in the yaml file with the syntax resembling 
  # ABNF grammar.
  # MutationSimplify currently supports only DepthFirst and DepthLocus mappers.
  #
  # The rules are stored in the YAML format file and read by the filename= method. The YAML file represents the array of
  # modification rules, each rule is the YAML object which has the mandatory attributes (pattern, replacement) and 
  # can have optional attributes (comment, lambdas).
  # Pattern and replacement attributes are arrays of derivation rules matching the grammar of the GE process.
  # Symbols in pattern array have to be qualified in the form:
  #
  #  symbol.instance
  #
  # The rule may have the right-hand side (it then represents a single derivation rule from the grammar) or the RHS
  # may be omitted (the symbol.instance left-hand side then represents the subtree defined in the pattern section). 
  # If there are two occurences of the same subtree instances then both subtrees must match.
  # See the example of the format: sample/toy_regression/simplify.yaml
  #    
  class MutationSimplify
    Expansion = Struct.new( :symbol, :alt_idx, :dir, :parent_arg )
    Subtree = Struct.new( :dir, :parent_arg )
    RuleCase = Struct.new( :match, :outcome, :equals  )

    # Create the simplification operator.
    # grammar is the valid grammar compatible with the simplification rules. 
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

    # Array of RuleCase structures representing the modification rules. See the class description for details.
    attr_accessor :rules

    # must be set to DepthFirst or DepthLocus. Other mapper types are not supported.
    attr_accessor :mapper_type

    # Reads the modification rules from the YAML file.
    # See the class description for details.
    def filename= fname
      @rules = parse_rules( YAML::load( File.open(fname) ) )
    end

    # Perform the mutation according the modification rules. See the class description for details.
    # parent is the original genotype.
    # track is the genotype-prenotype process track (see mappers descriptions).
    # Return the mutated copy of the orig. genotype.
    def mutation( parent, track )
      wrapped = wrapped_copy( parent, track )     
      mutant, track_reloc = reloc(wrapped, track)

      @rules.each do |rule|
        ptm = match( track_reloc, rule.match )
        next if ptm.empty?
        next unless check_equals( track_reloc, rule.equals, ptm )
        return replace( mutant, ptm, rule.match, rule.outcome, track_reloc )
      end
      mutant
    end

    def wrapped_copy( parent, track )
      mutant = []
      mutant += parent.clone while mutant.size < track.first.to+1
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
     replacement.each_with_index do |replacing,i|
       if replacing.kind_of? Expansion
         res << (i==0 ? root_node.loc_idx : 0) if @mapper_type == 'DepthLocus' # TODO: different Codon types?
         if replacing.alt_idx.respond_to? 'call'
           out = replacing.alt_idx.call args
           return genome.clone if out.nil?  
           res << text2alt_idx( replacing.symbol, out )
         else 
           res << replacing.alt_idx
         end
       else # replacing is the subtree index
         node = track_reloc[ ptm[replacing] ]
         subtree = genome[node.from .. node.to].clone
         subtree[0] = root_node.loc_idx if @mapper_type == 'DepthLocus' and i==0 # TODO: different Codon types?
         res.concat subtree
       end
     end
    
     res.concat genome[(root_node.to+1) ... genome.size] 
     res
    end
   
    def reloc(wrapped, track)
      case @mapper_type     
      when 'DepthFirst'
        reloc_first(wrapped, track)
      when 'DepthLocus'
        reloc_locus(wrapped, track)
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

    def text2alt_idx( symbol, text, hash=@grammar_texts )
      found = hash[symbol]
      raise "MutationSimplify: altidx for symbol '#{symbol}' not found" if found.nil?
      res = found[text]
      raise "MutationSimplify: altidx for RuleAlt '#{text}' (symbol '#{symbol}') not found" if res.nil?
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
          uses << rule.scan(/[a-zA-Z_\-][a-zA-Z0-9_\-]*\.[a-zA-Z_\-][a-zA-Z0-9_\-]*/)
          rule = rule.strip.gsub(/\.[a-zA-Z_\-][a-zA-Z0-9_\-]*/,'')
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
          rule.strip!
          all,fn = /([a-zA-Z_\-][a-zA-Z0-9_\-]*)\(\)/.match(rule).to_a
          if fn.nil?
            alt_idx = text2alt( symb, rule )   
          else
            raise "MutationSimplify: unknown lambda '#{fn}()'" unless lambdas.has_key? fn
            alt_idx = lambdas[fn]
          end
          replacement << Expansion.new( symb, alt_idx )
        else
          replacement << idx
        end
      end

      replacement
    end

    def parse_equals refs
      res = []
      refs.each_with_index do |ref,idx|
        for i in idx+1 ... refs.size
          res << [idx, i] if ref == refs[i]
        end
      end
      res
    end

    protected

    def reloc_first(wrapped, track)
      rel = track.clone
      counts = {}
      counts.default = 0

      rel.each do |node|
        node.loc_idx = counts[node.back]
        counts[node.back] += 1
      end

      [wrapped, rel]
    end

    FifoItem = Struct.new( :index, :track )

    def reloc_locus(wrapped, track)
      genome = []
      outrack = []
      stack = [ FifoItem.new(0, track.first) ]

      until stack.empty?
        node = stack.shift

        out = node.track.clone
        idx = out.from

        out.from = genome.size
        genome.push 0 # loc
        genome.push wrapped[idx+1] # alt

        expansion = []
        track.each_with_index do |n, i|
          next unless n.back == node.index
          childnode = FifoItem.new( i, n.clone )
          childnode = FifoItem.new( i, n.clone )
          childnode.track.back = outrack.size
          expansion.push childnode
        end

        used = out.from + 1
        out.to = used

        outrack.push out

        back = out.back
        until back.nil?
          outrack[back].to = used
          back = outrack[back].back
        end

        indices = []
        (0...expansion.size).each {|i| indices << i }
        expansion.each {|ext| ext.track.loc_idx = indices.delete_at(ext.track.loc_idx) }
        expansion.sort! {|a,b| a.track.loc_idx <=> b.track.loc_idx }
        stack = expansion + stack
      end

      [genome, outrack]
    end

    def alt2text( symbol, alt_idx )
      (@grammar[symbol][alt_idx].map {|t| t.type == :symbol ? t.data : %Q["#{t.data}"] }).join(' ')
    end

    def text2alt( symbol, text )
      text2alt_idx( symbol, text, hash=@grammar_texts2 )
    end
   
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

    def match_node?( node, pattern )
      node.symbol == pattern.symbol and ( pattern.alt_idx.nil? or node.alt_idx == pattern.alt_idx )
    end

  end

end # Operator

