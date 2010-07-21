
require 'lib/mapper_base'

module Mapper

  # "Sensible Initialization" of genotypes for Grammatical Evolution.
  #
  # See: 
  # Grammatical Evolution: Evolutionary Automatic Programming in an Arbitrary Language, section 8.8:
  # http://www.springer.com/computer/artificial/book/978-1-4020-7444-8
  # 
  # or:
  # http://www-dept.cs.ucl.ac.uk/staff/W.Langdon/ftp/papers/azad_thesis.ps.gz 
  # Chapter 7 Sensible Initialisation
  #
  # or:
  # http://www.essex.ac.uk/dces/research/publications/technicalreports/2007/ces475.pdf
  # 
  # Mapper::Generator uses Mapper::Grammar and the source of randomness to create 
  # "syntactically correct" genotypes with a given depth of a phenotype tree.
  #
  class Generator < Base

    # Initialize the generator with the arguments necessary for Mapper::Base#initialize
    def initialize *args
      super
      @random = Kernel
    end
 
    # Set the source of randomness (for testing purposes).
    def random= rnd 
      @random = rnd
      @codon.random = rnd
    end

    # The source of randomness, used for calling "random.rand( limit )", defaulting to 'Kernel' class.
    attr_reader :random 
 
    # Generate the genotype using the "full" method:
    # if the depth of the current node is smaller, 
    # then select only :cyclic nodes for a deeper level,
    # otherwise select only :terminating nodes.
    #
    # See also Mapper::Validator.analyze_recursivity for discussion of node recursivity types. 
    def generate_full required_depth 
      generate( [:cyclic], required_depth )
    end

    # Generate the genotype using the "grow" method:
    # if the depth of the current node is smaller, 
    # then select :cyclic and/or :terminating nodes for a deeper level,
    # otherwise select only :terminating nodes.
    # 
    # See also Mapper::Validator.analyze_recursivity for discussion of node recursivity types. 
    def generate_grow required_depth 
      generate( [:cyclic, :terminating], required_depth )
    end

    # Generate the genotype using the recursivity information.
    # The recursivity argument is the array of allowed node recursivity types (before the required_depth is reached).
    # Mapper::Generator#generate_full uses [:cyclic], Mapper::Generator#generate_grow uses [:cyclic, :terminating].
    def generate( recursivity, required_depth )
      genome = []
      tokens = [ Token.new( :symbol, @grammar.start_symbol, 0 ) ]

      until ( selected_indices = find_nonterminals( tokens ) ).empty?
        selected_index = generate_locus( selected_indices, genome )
        selected_token = tokens[selected_index]

        selected_symbol = selected_token.data
        return genome if @grammar[selected_symbol].recursivity == :infinite # emergency fallback     

        rec = (selected_token.depth < required_depth) ? recursivity : [:terminating]
        expansion = generate_rule( rec, selected_token, genome, required_depth-selected_token.depth )
        expansion.each { |t| t.depth = selected_token.depth+1 }

        tokens = apply_expansion( tokens, expansion, selected_index )
       
      end
     
      genome
    end
   
  protected

    def generate_rule( recurs, symbol_token, genome, allowed_depth )
      rule = pick_expansions( symbol_token, genome )
      allowed = filter_expansions_by_depth( rule, allowed_depth )
      alts = allowed.find_all { |alt| recurs.include? alt.recursivity }
      alts = allowed if alts.empty? # deep grammars, cannot prefer recurs
      if @consume_trivial_codons or rule.size > 1
        alt = alts.at @random.rand( alts.size )
        genome.push unmod( rule.index(alt), rule.size, symbol_token.data ) #todo: change to:
        # genome << @codon.generate( rule.size, rule.index(alt), symbol_token.data )
      else
        alt = rule.first 
      end
      return use_expansion( symbol_token, alt.deep_copy )
    end

    def filter_expansions_by_depth( rule, allowed_depth )
      allowed = rule.find_all { |alt| not alt.min_depth.nil? and alt.min_depth <= allowed_depth }
      raise "Generator: required_depth<min_depth, please increase sensible_depth" if allowed.empty? 
      allowed
    end

  end # Generator
  
  module PolyIntrinsic #todo: remove 
    protected
    def unmod( index, base, symbol ) # -> @codon.generate
      @codon.generate( base, index, symbol )
    end
  end

  module PolyBucket #todo: remove
    protected
    def unmod( index, base, symbol )  # -> @codon.generate
      init_bucket unless defined? @bucket
      @codon.generate( base, index, symbol ) * @bucket[symbol] 
    end
  end
 
  module LocusFirst
    protected   
    def generate_locus( selected_indices, genome )
      selected_indices.first
    end
  end

  module LocusGenetic
    protected   
    def generate_locus( selected_indices, genome )
      if @consume_trivial_codons or selected_indices.size > 1
        index = @random.rand( selected_indices.size )
        genome << @codon.generate( selected_indices.size, index )
      else
        index = 0 
      end
      selected_indices.at index
    end
  end
 
end # Mapper
