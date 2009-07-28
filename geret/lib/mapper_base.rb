
require 'lib/grammar'
require 'lib/validator'

module Mapper

  # The support for the mapper_support array. See mapper_support attribute.
  TrackNode = Struct.new( 'TrackNode', :symbol, :from, :to )  

  # The core Grammatical Evolution genotype->phenotype mapper.
  # It generates a program (phenotype) according syntactic rules (Mapper::Grammar).
  # The selection of rules is driven by the vector of numbers (genotype),
  # 
  # See: 
  # http://www.grammatical-evolution.org/ 
  # https://eprints.kfupm.edu.sa/43213/1/43213.pdf 
  #   
  class Base

    # The required parameter is the grammar (Mapper::Grammar).
    # 
    # Optional wraps_to_fail argument specifies the maximal number of genotype wrappings. If the genotype vector is used
    # wraps_to_fail times, the maping fails. Default is 1.
    #  
    # Optional wraps_to_fading argument specifies the number of genotype wrappings during which all possible 
    # (:terminating and/or :cyclic) rule alternations (Mapper::RuleAlt) can be selected from. 
    # After wraps_to_fading wrappings only the :terminating rule alternations are available for selection. 
    # If wraps_to_fading is set to nil (default), the fading strategy is turned off.
    # See also Validator.analyze_recursivity.
    # 
    # If the optional consume_trivial_codons argument is set to true (default), the allele codons are used 
    # even if the number of rule alternations for selecting from is 1. Set to false if the codons should 
    # not be "wasted" during such trivial decision cases.
    # Note that setting consume_trivial_codons=false can have undesirable effect when used alongside the "bucket-rule": 
    # The number of used codons cannot be asumed even because of skipped codons. See Mapper::DepthBucket.
    # 
    def initialize( grammar, wraps_to_fail=1, wraps_to_fading=nil, consume_trivial_codons=true )
      @grammar = Validator.analyze_recursivity grammar 
      @wraps_to_fail = wraps_to_fail
      @wraps_to_fading = wraps_to_fading
      @consume_trivial_codons = consume_trivial_codons 
      @track_support_on = false
    end
  
    # The grammar used.
    attr_reader :grammar

    # The number of codons used by the last mapping process. This value is set by the previous Mapper::Base#phenotype call.
    # Note the used_length may be greather than the genotype.size because of the wrapping effect.
    attr_reader :used_length

    # See Mapper::Base#initialize
    attr_accessor :wraps_to_fail, :wraps_to_fading, :consume_trivial_codons 

    # true means the mapper_support for LHS Crossover is turned on 
    attr_accessor :track_support_on
    
    # The output array for the LHS Crossover support. (See Operator::CrossoverLHS for explanation)
    attr_accessor :track_support
    
    # Take the genome (the vector of Fixnums) and use it for the genotype->phenotype mapping.
    # Returns the phenotype string (or nil if the mapping process fails).
    def phenotype genome
      return nil if genome.empty?

      tokens = [ Token.new( :symbol, @grammar.start_symbol, 0 ) ]
      tokens.first.track = [0,[]] if @track_support_on
      @used_length = 0
      @track_support = nil 
      
      until ( selected_indices = find_nonterminals( tokens ) ).empty?
      
        return nil if enough_wrapping genome       
        selected_index = pick_locus( selected_indices, genome )
        selected_token = tokens[selected_index]

        return nil if enough_wrapping genome
        expansion = pick_rule( selected_token.data, genome )
        expansion.each { |t| t.depth = selected_token.depth+1 }
        track_expansion( selected_token, expansion ) if @track_support_on
        tokens[selected_index,1] = expansion

      end

      track_backtrack( tokens ) if @track_support_on
      return ( tokens.collect {|t| t.data} ).join
    end
  
  protected

    def track_expansion( symbol_token, tokens )
      @track_support = [] if @track_support.nil?
      ary = symbol_token.track.last.clone
      ary.push  @track_support.size
      tokens.each { |t| t.track = [ @used_length-1, ary.clone ] }
      @track_support.push TrackNode.new( symbol_token.data )
    end
    
    def track_backtrack tokens
      tokens.each do |t|
        t.track.last.each do |i| 
          node = @track_support[i]
          node.from = t.track.first if node.from.nil? or t.track.first < node.from
          node.to = t.track.first if node.to.nil? or t.track.first > node.to
        end
      end
    end
 
    def enough_wrapping genome
      if @used_length > @wraps_to_fail*genome.size
        @used_length -= 1
        return true
      end
      false
    end
    
    def read_genome_rule( genome, rule )
      if not @wraps_to_fading.nil? and @used_length > @wraps_to_fading*genome.size     
        @used_length += 1
        terminal = rule.find {|alt| alt.recursivity == :terminating }
        return 0 if terminal.nil? # desperate case (only :cyclic or :infinite alts found)
        return rule.index( terminal )
      end  
      read_genome( genome, rule.size )   
    end

    def read_genome( genome, choices )
      return 0 if choices == 1 and @consume_trivial_codons == false     
   
      index = @used_length.divmod( genome.size ).last
      @used_length += 1     
      genome.at( index )
    end
   
    def pick_rule( symbol, genome )
      rule = @grammar.fetch( symbol )
      alt_index = polymorphism( symbol, read_genome_rule( genome, rule ) )
      alt_index = alt_index.divmod( rule.size ).last 
      alt = rule.at alt_index
      return alt.deep_copy
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
    protected
    def polymorphism( symbol, value )
      value
    end
  end

  module PolyBucket
    protected 
    def init_bucket
      @bucket = {}
      @maxAllele = 1
      @grammar.symbols.each do |sym|
        alts = @grammar[sym] 
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
      index = read_genome( genome, selected_indices.size ).divmod( selected_indices.size ).last    
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

  module ExtendAll
    protected   
    def find_nonterminals tokens 
      indices = []
      tokens.each_with_index { |tok,i| indices.push i if tok.type == :symbol }
      indices
    end
  end

end # Mapper
