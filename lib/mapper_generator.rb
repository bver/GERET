
require 'lib/mapper_base'

module Mapper

  # "Sensible Initialization" of genotypes for Grammatical Evolution.
  # See http://www.essex.ac.uk/dces/research/publications/technicalreports/2007/ces475.pdf
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
 
    # The source of randomness, used for calling "random.rand( limit )", defaulting to 'Kernel' class.
    attr_accessor :random 
 
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
      alts = rule if alts.empty? # desperate case, cannot obey recurs
      if @consume_trivial_codons or rule.size > 1
        alt = alts.at @random.rand( alts.size )
        genome.push unmod( rule.index(alt), rule.size, symbol )
      else
        alt = rule.first 
      end
      alt.deep_copy
    end

  end # Generator
  
  module PolyIntrinsic
    protected
    def unmod( index, base, symbol )
      unless defined? @max_codon_base
        @max_codon_base = (@grammar.max { |rule1,rule2| rule1.size<=>rule2.size } ).size+1
      end
      return index if @max_codon_base/base == 0
      base * @random.rand( @max_codon_base/base ) + index
    end

    public
    attr_accessor :max_codon_base 
  end

  module PolyBucket
    protected
    def unmod( index, base, symbol )
      init_bucket unless defined? @bucket
      index * @bucket[symbol]
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
        genome.push index 
      else
        index = 0 
      end
      selected_indices.at index
    end
  end
 
end # Mapper