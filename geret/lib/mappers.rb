
require 'lib/grammar'

module Mapper

  class Base
    def initialize( grammar, wraps_to_fail=1 )
      @grammar = Grammar.new grammar
      @wraps_to_fail = wraps_to_fail
    end
  
    attr_reader :grammar, :used_length
    attr_accessor :wraps_to_fail

    def phenotype genome
      tokens = [ Token.new( :symbol, @grammar.start_symbol, 0 ) ]
      @used_length = 0

      until ( selected_indices = find_nonterminals( tokens ) ).empty?

        selected_index = pick_locus( selected_indices, genome )
        selected_token = tokens[selected_index]

        return nil if enough_wrapping genome
        expansion = pick_rule( selected_token.data, genome )

        expansion.each { |t| t.depth = selected_token.depth+1 }
        tokens[selected_index,1] = expansion
      end

      return (tokens.collect {|t| t.data} ).join
    end
  
  protected

    def enough_wrapping genome
      if @used_length > @wraps_to_fail*genome.size
        @used_length -= 1
        return true
      end
      false
    end
    
    def read_genome genome
      index = @used_length.divmod( genome.size ).last
      @used_length += 1     
      genome.at( index )
    end

    def pick_rule( symbol, genome )
      rule = @grammar.fetch(symbol)
      alt_index = polymorphism( symbol, read_genome(genome) )
      alt_index = alt_index.divmod( rule.size ).last 
      rule_alt = rule[ alt_index ]
      rule_alt.deep_copy
    end

    def find_nonterminals_by_depth( tokens, depth )
      indices = []
      tokens.each_index do |i| 
        indices.push i if tokens[i].type == :symbol and tokens[i].depth==depth
      end
      indices
    end
   
  end # Base

  module PolyIntrinsic
    def polymorphism( symbol, value )
      value
    end
  end

  module PolyBucket
    def init_bucket
      @bucket = {}
      @maxAllele = 1
      @grammar.each_pair do |sym,alts|
        @bucket[sym] = @maxAllele
        @maxAllele *= alts.size
      end
    end

    def polymorphism( symbol, value )
      init_bucket unless defined? @bucket
      value.divmod( @bucket[symbol] ).first
    end
  end
 
  module LocusFirst
  protected   
    def pick_locus( selected_indices, genome )
      selected_indices.first 
    end
  end

  module LocusGenetic
  protected   
    def pick_locus( selected_indices, genome )
      index = read_genome(genome).divmod( selected_indices.size ).last    
      selected_indices[index]     
    end
  end

  module ExtendDepth
  protected   
    def find_nonterminals tokens
      max = nil
      tokens.each { |t| max = t.depth if t.type==:symbol and ( max.nil? or t.depth>max ) }
      find_nonterminals_by_depth( tokens, max )
    end
  end

  module ExtendBreadth
  protected   
    def find_nonterminals tokens 
      min = nil
      tokens.each { |t| min = t.depth if t.type==:symbol and ( min.nil? or t.depth<min ) }
      find_nonterminals_by_depth( tokens, min )
    end
  end

  class DepthFirst < Base
    include LocusFirst
    include ExtendDepth
    include PolyIntrinsic 
  end

  class BreadthFirst < Base
    include LocusFirst
    include ExtendBreadth
    include PolyIntrinsic 
  end

  class DepthLocus < Base
    include LocusGenetic
    include ExtendDepth
    include PolyIntrinsic 
  end

  class BreadthLocus < Base
    include LocusGenetic
    include ExtendBreadth
    include PolyIntrinsic 
  end

  class DepthBucket < Base
    include LocusFirst
    include ExtendDepth
    include PolyBucket 
  end

  class BreadthBucket < Base
    include LocusFirst
    include ExtendBreadth
    include PolyBucket 
  end

 
end # Mapper
