
require 'lib/mappers'

module Mapper

  class Generator < Base
    def initialize *args
      super
      @random = Kernel::rand
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
      depth = 0     
      tokens = [ Token.new( :symbol, @grammar.start_symbol, depth ) ]

      # deepenning phase
      while depth < required_depth 
        selected_indices = find_nonterminals( tokens )
        return genome if selected_indices.empty?
        depth = generate_dry( selected_indices, recursivity, genome, tokens ) 
#puts "XXXX   " +  ( tokens.collect {|t| t.data} ).join( ' ' ) + "depth="+ depth.to_s
      end

      # terminating phase
      until ( selected_indices = find_nonterminals( tokens ) ).empty?
        generate_dry( selected_indices, [:terminating], genome, tokens )      
#puts "YYYY   " +  ( tokens.collect {|t| t.data} ).join( ' ' ) 
      end
     
      genome
    end
   
  protected

    def generate_dry( selected_indices, recursivity, genome, tokens )
      selected_index = generate_locus( recursivity, selected_indices, tokens, genome )
      selected_token = tokens[selected_index]

      expansion = generate_rule( recursivity, selected_token.data, genome )
      expansion.each { |t| t.depth = selected_token.depth+1 }

      tokens[selected_index,1] = expansion
      tokens.clear if @grammar[selected_token.data].recursivity == :infinite # emergency fallback      

      expansion.first.depth        
    end

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
 

  class GeneratorDepthFirst < Generator
    include LocusFirst
    include ExtendDepth
    include PolyIntrinsic 
  end

  class GeneratorBreadthFirst < Generator
    include LocusFirst
    include ExtendBreadth
    include PolyIntrinsic 
  end

  class GeneratorDepthLocus < Generator
    include LocusGenetic
    include ExtendDepth
    include PolyIntrinsic 
  end

  class GeneratorBreadthLocus < Generator
    include LocusGenetic
    include ExtendBreadth
    include PolyIntrinsic 
  end

  class GeneratorDepthBucket < Generator
    include LocusFirst
    include ExtendDepth
    include PolyBucket 
  end

  class GeneratorBreadthBucket < Generator
    include LocusFirst
    include ExtendBreadth
    include PolyBucket 
  end

 
end # Mapper
