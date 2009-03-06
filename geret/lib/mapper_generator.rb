
require 'lib/mapper_base'

module Mapper

  class Generator < Base
    def initialize *args
      super
      @random = Kernel
    end
 
    attr_accessor :random 
 
    def generate_full required_depth 
      generate_genome( [:cyclic], required_depth )
    end

#    def generate_grow required_depth 
#      generate_genome( [:cyclic, :terminating], required_depth )
#    end

    def generate_genome( recursivity, required_depth )
      genome = []
      tokens = [ Token.new( :symbol, @grammar.start_symbol, 0 ) ]

      until ( selected_indices = find_nonterminals( tokens ) ).empty?
        selected_index = generate_locus( recursivity, selected_indices, tokens, genome )
        selected_token = tokens[selected_index]
#puts  selected_token.inspect       
        selected_symbol = selected_token.data
        return genome if @grammar[selected_symbol].recursivity == :infinite # emergency fallback     

        rec = (selected_token.depth < required_depth) ? recursivity : [:terminating]
        expansion = generate_rule( rec, selected_symbol, genome )
        expansion.each { |t| t.depth = selected_token.depth+1 }

        tokens[selected_index,1] = expansion
      end
     
      genome
    end
   
  protected

     def generate_rule( recurs, symbol, genome )
      rule = @grammar.fetch( symbol )
      alts = rule.find_all { |alt| recurs.include? alt.recursivity }
      # todo: @consume_trivial_codons
      alts = rule if alts.empty? # desperate case, cannot obey recurs
      alt = alts.at @random.rand( alts.size )  
      genome.push unmod( rule.index(alt), rule.size )
      alt.deep_copy
    end

  end # Generator
  
  module PolyIntrinsic
    protected
    def unmod( index, base )
      unless defined? @max_codon_base
        @max_codon_base = (@grammar.max { |rule1,rule2| rule1.size<=>rule2.size } ).size+1
      end
      return index if @max_codon_base/base == 0
      base * @random.rand( @max_codon_base/base ) + index
    end

    public
    attr_accessor :max_codon_base 
  end

  module LocusFirst
    protected   
    def generate_locus( recursivity, selected_indices, tokens, genome )
      selected_indices.first
    end
  end

  module LocusGenetic
    protected   
    def generate_locus( recurs, selected_indices, tokens, genome )
      pairs = selected_indices.map { |i| [tokens[i], i] }
      toks = pairs.find_all {|pair| recurs.include? @grammar[ pair.first.data ].recursivity }
      toks = pairs if toks.empty? #desperate case, cannot obey recurs
      tok = toks.at @random.rand( toks.size )
      # todo: @consume_trivial_codons     
      genome.push selected_indices.index(tok.last) 
      tok.last
    end
  end
 
end # Mapper
