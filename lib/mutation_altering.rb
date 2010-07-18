
module Operator

  # Common functionality for MutationNodal and MutationStructural classes. 
  class MutationAltering

    # Create the mutation operator.
    # grammar is the valid grammar for distinguishing :structural and :nodal symbols
    def initialize( grammar )
      @grammar = grammar
      @random = Kernel
      @codon = CodonMod.new # standard 8-bit codons
    end

    # Codon encoding scheme. By default the instance of the CodonMod class is used (ie. standard GE 8-bit codons)
    # See CodonMod for details.
    attr_accessor :codon
    
    # The source of randomness, used for calling "random.rand( limit )", defaulting to 'Kernel' class.
    attr_reader :random
   
    # Set the source of randomness (for testing purposes).
    def random= rnd 
      @random = rnd
      @codon.random = rnd
    end
    
    # Select the random (nodal/structural filtered) position within the orig vector and mutate it.
    # The resultant value (of a mutated codon) is bit-mutated by self.codon.mutate_bit method.
    # Return the mutated copy of the orig. genotype.
    # track argument is the hint (symbols atteched to positions) obtained from Mapper::Base#track_support 
    #
    def mutation( orig, track )
      mutant = orig.clone
      filtered_track = track.find_all { |node| @grammar[ node.symbol ].sn_altering == filter }
      return mutant if filtered_track.empty?
      where = @random.rand( filtered_track.size )
      index = filtered_track[where].from 
      mutant[ index ] = @codon.mutate_bit( mutant.at(index) )
      mutant
    end
   
  end

  # Structural mutation (see http://portal.acm.org/citation.cfm?id=1570215).
  # It assumes the source genotype has the form of the Array of numbers.
  # Select codons with Token#sn_altering == :structural for mutation.
  # Structural change means the length of genotype->phenotype transformation process CAN change for mutated genotype.
  #
  class MutationStructural < MutationAltering
    protected
    def filter
      :structural 
    end
  end

  # Nodal mutation (see http://portal.acm.org/citation.cfm?id=1570215).
  # It assumes the source genotype has the form of the Array of numbers.
  # Select codons with Token#sn_altering == :nodal for mutation.
  # Nodal change means the length of genotype->phenotype transformation process CANNOT change for mutated genotype. 
  #
  class MutationNodal < MutationAltering
    protected
    def filter
      :nodal
    end
  end

end # Operator

