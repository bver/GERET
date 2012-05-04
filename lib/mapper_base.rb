
require 'lib/grammar'
require 'lib/codon_mod'
require 'lib/mapper_constants'

module Mapper

  # The support for the mapper_support array. See mapper_support attribute.
  # :symbol is the rule name used during a single genotype->phenotype mapping step,
  # :from is the index of the first codon 'covered' by the rule,
  # :to is the index of the last codon 'covered' by the rule.
  # :back is the reference to the parent TrackNode
  # :alt_idx is the index of the expansion in a given rule so that grammar[symbol][alt_idx] is the selected expansion
  # :loc_idx is the locus index in the parent expansion
  TrackNode = Struct.new( 'TrackNode', :symbol, :from, :to, :back, :alt_idx, :loc_idx )  

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
    # even if the number of rule alternations for selecting from is 1. Set it to false if the codons should 
    # not be "wasted" during such trivial decision cases.
    # Note that setting consume_trivial_codons=false may affect the functionality of genetic operators, due
    # to the number of used codons which is not always an even number.
    # 
    def initialize( grammar, wraps_to_fail=1, wraps_to_fading=nil, consume_trivial_codons=true )
      @grammar = grammar
      @wraps_to_fail = wraps_to_fail
      @wraps_to_fading = wraps_to_fading
      @consume_trivial_codons = consume_trivial_codons 
      @track_support_on = false
      @codon = CodonMod.new # standard 8-bit codons
      @mapped_count = 0
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
    # http://scholar.google.cz/scholar?cluster=18084534358495618318&hl=en&as_sdt=0,5
    #
    attr_reader :complexity
    
    # Codon encoding scheme. By default the instance of the CodonMod class is used (ie. standard GE 8-bit codons)
    # See CodonMod for details.
    attr_accessor :codon

    # Total number of phenotypes mapped, from the initialisation (for diagnostic purposes).
    attr_reader :mapped_count
    
    # Take the genome (the vector of Fixnums) and use it for the genotype->phenotype mapping.
    # Returns the phenotype string (or nil if the mapping process fails).
    def phenotype genome
      @mapped_count += 1
      @fading = @wraps_to_fading 

      return nil if genome.empty?

      tokens = [ Token.new( :symbol, @grammar.start_symbol, 0 ) ]
      @used_length = 0
      @track_support = nil 
      @complexity = 1 
      length_limit = @wraps_to_fail*genome.size

      until ( selected_indices = find_nonterminals( tokens ) ).empty?
      
        tsi1 = @used_length
        return nil if @used_length > length_limit
        selected_index, loc_idx = pick_locus( selected_indices, genome )
        selected_token = tokens[selected_index]

        return nil if @used_length > length_limit
        expansion, alt_idx = pick_rule( selected_token, genome )
        expansion.each { |t| t.depth = selected_token.depth+1 }

        @complexity += selected_token.depth * expansion.arity + 1
        track_expansion( selected_token, expansion, tsi1, alt_idx, loc_idx ) if @track_support_on

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

    def track_expansion( symbol_token, tokens, tsi1, alt_idx, loc_idx )
      @track_support = [] if @track_support.nil?
      tsi2 = @used_length-1 
      back = symbol_token.track

      tokens.each { |t| t.track = @track_support.size if t.type == :symbol }
      @track_support.push TrackNode.new( symbol_token.data, tsi1, tsi2, back, alt_idx, loc_idx )
     
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

      return rules if @fading.nil? or @used_length <= @fading*genome.size
      
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
 
      alt_index = @codon.interpret( rule.size, faded_index, symbol_token.data ) 

      expansion = rule.at(alt_index).deep_copy
      modify_expansion_base( expansion, genome )     
      return [ use_expansion( symbol_token, expansion ), alt_index ]
    end

    def find_nonterminals_by_depth( tokens, depth )
      indices = []
      tokens.each_index do |i| 
        indices.push i if tokens[i].type == :symbol and tokens[i].depth==depth
      end
      indices
    end
   
  end # Base

  module LocusFirst
    protected   
    def pick_locus( selected_indices, genome )
      return [selected_indices.first, 0]
    end
  end

  module LocusGenetic
    protected   
    def pick_locus( selected_indices, genome )
      index = @codon.interpret( selected_indices.size, read_genome( genome, selected_indices.size ) )  
      return [selected_indices[index], index]
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

  module ConstantsNoSupport
    def modify_expansion_base( exp, genome )
      exp
    end
  end

end # Mapper
