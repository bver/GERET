
require 'lib/mapper_types'

module Mapper

  class Base
    def initialize grammar
      @grammar = Grammar.new grammar
    end
  
    attr_reader :grammar, :used_length

    def phenotype genome
      tokens = [ Token.new( :symbol, @grammar.start_symbol, 0 ) ]
      @used_length = 0

      until ( selected_indices = find_nonterminals( tokens ) ).empty?
        selected_index, genome = pick_locus( selected_indices, genome )
        return nil if genome.nil?       
        selected = tokens[selected_index]
        expansion, genome = pick_rule( selected.data, genome )
        return nil if genome.nil?
        expansion.each { |t| t.depth = selected.depth+1 }
        tokens[selected_index,1] = expansion
      end

      return (tokens.collect {|t| t.data} ).join
    end
  
  protected

    def pick_rule( symbol, genome )
      return nil, nil if genome.empty?
      rule = @grammar.fetch(symbol)
      poly = polymorphism( symbol, genome.at(@used_length) )
      @used_length+=1
      alt_index = poly.divmod( rule.size ).last 
      rule_alt = rule[ alt_index ]
      return rule_alt.deep_copy, genome
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
      return selected_indices.first, genome 
    end
  end

  module LocusGenetic
  protected   
    def pick_locus( selected_indices, genome )
      return nil, nil if genome.empty?     
      index = genome.at(@used_length).divmod( selected_indices.size ).last    
      @used_length+=1
      return selected_indices[index], genome     
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
