
require 'lib/grammar'
require 'lib/codon_mod'

module Mapper

  # The support for the mapper_support array. See mapper_support attribute.
  # :symbol is the rule name used during a single genotype->phenotype mapping step,
  # :from is the index of the first codon 'covered' by the rule,
  # :to is the index of the last codon 'covered' by the rule.
  TrackNode = Struct.new( 'TrackNode', :symbol, :from, :to, :back )  

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
    # repetitively wraps_to_fail times, the maping fails. Default is 1.
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
      @grammar = grammar
      @wraps_to_fail = wraps_to_fail
      @wraps_to_fading = wraps_to_fading
      @consume_trivial_codons = consume_trivial_codons 
      @track_support_on = false
      @codon = CodonMod.new # standard 8-bit codons
    end
  
    # The grammar used.
    attr_reader :grammar

    # The number of codons used by the last mapping process. This value is set by the previous Mapper::Base#phenotype call.
    # Note the used_length may be greather than the genotype.size because of the wrapping effect.
    attr_reader :used_length

    # See Mapper::Base#initialize
    attr_accessor :wraps_to_fail, :wraps_to_fading, :consume_trivial_codons 

    # true means the track_support for LHS Crossover is turned on 
    attr_accessor :track_support_on
    
    # The output array of the TrackNodes. (See Operator::CrossoverLHS and Mapper::TrackNode for explanation.)
    attr_reader :track_support

    # The complexity of the expression is the complexity of its root node. 
    # The complexity of the node i is recursively defined as:
    #    complexity(i) = node_count(i) + sum_over_all_subnodes_of_i( complexity(subnode) )
    #    node_count(i) = 1 + sum_over_all_subnodes_of_i( node_count(subnode) )
    #
    # See:
    # http://www.evolved-analytics.com/selected_publications/legacy_publications/gptp-04_pareto-front_exploi.html   
    #
    attr_reader :complexity
    
    # Codon encoding scheme. By default the instance of the CodonMod class is used (ie. standard GE 8-bit codons)
    # See CodonMod for details.
    attr_accessor :codon

    # Take the genome (the vector of Fixnums) and use it for the genotype->phenotype mapping.
    # Returns the phenotype string (or nil if the mapping process fails).
    def phenotype genome
      return nil if genome.empty?

      tokens = [ Token.new( :symbol, @grammar.start_symbol, 0 ) ]
#      tokens.first.track = -1 if @track_support_on
      @used_length = 0
      @track_support = nil 
      @complexity = 1 
      length_limit = @wraps_to_fail*genome.size

      until ( selected_indices = find_nonterminals( tokens ) ).empty?
      
        tsi1 = @used_length
        return nil if @used_length > length_limit
        selected_index = pick_locus( selected_indices, genome )
        selected_token = tokens[selected_index]

        return nil if @used_length > length_limit
        expansion = pick_rule( selected_token, genome )
        expansion.each { |t| t.depth = selected_token.depth+1 }

        @complexity += selected_token.depth * expansion.arity + 1
        track_expansion( selected_token, expansion, tsi1 ) if @track_support_on

        tokens = apply_expansion( tokens, expansion, selected_index )

      end

      return ( tokens.collect {|t| t.data} ).join
    end
  
  protected
   
    def apply_expansion( tok, exp, i )
      if i > 0 and exp.first.type == :literal and tok[i-1].type == :literal 
        tok[i-1].data += exp.shift.data       
      end

      if !exp.empty? and i+1 < tok.size and exp.last.type == :literal and tok[i+1].type == :literal
        tok[i+1].data = exp.pop.data + tok[i+1].data       
      end
 
      tok[i,1] = exp     
      tok
    end

    def track_expansion( symbol_token, tokens, tsi1 )
      @track_support = [] if @track_support.nil?
      tsi2 = @used_length-1 
      back = symbol_token.track

      tokens.each { |t| t.track = @track_support.size if t.type == :symbol }
      @track_support.push TrackNode.new( symbol_token.data, tsi1, tsi2, back )
     
      until back.nil?
        @track_support[back].to = tsi2
        back = @track_support[back].back
      end
    end
   
    def read_genome( genome, choices )
      return 0 if choices == 1 and @consume_trivial_codons == false     
   
      index = @used_length.divmod( genome.size ).last
      @used_length += 1     
      genome.at( index )
    end
   
    def pick_expansions( symbol_token, genome )
      rules = @grammar.fetch( symbol_token.data )

      return rules if @wraps_to_fading.nil? or @used_length <= @wraps_to_fading*genome.size
      
      terminals = rules.find_all { |alt| alt.recursivity == :terminating }
      return rules if terminals.empty? # desperate case (only :cyclic or :infinite nodes found)

      terminals
    end

    def use_expansion( symbol_token, alt )
      alt
    end

    def pick_rule( symbol_token, genome )
      rule = pick_expansions( symbol_token, genome )

      faded_index = read_genome( genome, rule.size )
 
      alt_index = polymorphism( symbol_token.data, faded_index )
      alt_index = @codon.interpret( rule.size, alt_index ) 
      alt = rule.at alt_index
      return use_expansion( symbol_token, alt.deep_copy )
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
      index = @codon.interpret( selected_indices.size, read_genome( genome, selected_indices.size ) )  
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
