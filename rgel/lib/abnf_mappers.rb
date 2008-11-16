
require 'lib/abnf_types'

module Mapper

  class SingleMapper
    def initialize grammar
      @grammar = Abnf::Grammar.new grammar
    end
  
    attr_reader :grammar

    def phenotype genome
      tokens = [ Abnf::Token.new( :symbol, @grammar.start_symbol, 0 ) ]
      
      until ( selected_indices = find_nonterminals( tokens ) ).empty?
        symbol_index = pick_locus( selected_indices.size )
        selected_index = selected_indices[symbol_index] 
        selected = tokens[selected_index]
        expansion, genome = pick_rule( selected.data, genome )
        return nil if genome.nil?
        expansion.each { |t| t.depth = selected.depth+1 }
        tokens[selected_index,1] = expansion
      end

      return (tokens.collect {|t| t.data} ).join
    end
  
  protected
    def pick_locus numof_loci
      0
    end

    def pick_rule( symbol, genome )
      return nil, nil if genome.empty?
      rule = @grammar.fetch(symbol) 
      alt_index = genome.shift.divmod( rule.size ).last 
      rule_alt = rule[ alt_index ]
      return rule_alt.map {|t| Abnf::Token.new(t.type,t.data) }, genome
    end

    def find_nonterminals_by_depth( tokens, depth )
      indices = []
      tokens.each_index {|i| indices.push i if tokens[i].type == :symbol and tokens[i].depth==depth }
      indices
    end
   
  end

  class DepthFirst < SingleMapper
  protected

    def find_nonterminals tokens
      max = nil
      tokens.each { |t| max = t.depth if t.type==:symbol and ( max.nil? or t.depth>max ) }
      find_nonterminals_by_depth( tokens, max )
    end

  end

  class BreadthFirst < SingleMapper
  protected

    def find_nonterminals tokens 
      min = nil
      tokens.each { |t| min = t.depth if t.type==:symbol and ( min.nil? or t.depth<min ) }
      find_nonterminals_by_depth( tokens, min )
    end
  
  end

end
