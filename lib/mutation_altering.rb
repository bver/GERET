
module Operator

  # Common functionality for MutationNodal and MutationStructural classes. 
  class MutationAltering

    # Create the mutation operator.
    # grammar is the valid grammar for distinguishing :structural and :nodal symbols
    # magnitude is the initial value of the MutationAltering#magnitude attribute
    def initialize( grammar, magnitude=nil )
      @grammar = grammar
      @random = Kernel
      @magnitude = magnitude
    end

    # The source of randomness, used for calling "random.rand( limit )", defaulting to 'Kernel' class.
    attr_accessor :random
   
    # The maximal possible value of the mutaton plus 1. If not specified, the maximal value over the original 
    # genotype values is used.
    attr_accessor :magnitude
   
    
    # Select the random (nodal/structural filtered) position within the orig vector and mutate it.
    # The resultant value (of a mutated codon) is a random number in the range 0..magnitude.
    # Return the mutated copy of the orig. genotype.
    # track argument is the hint (symbols atteched to positions) obtained from Mapper::Base#track_support 
    #
    def mutation( orig, track )
      mutant = orig.clone
      max = @magnitude.nil? ? mutant.max+1 : @magnitude
      filtered_track = track.find_all { |node| @grammar[ node.symbol ].sn_altering == filter }
      return mutant if filtered_track.empty?
      where = @random.rand( filtered_track.size )
      index = filtered_track[where].from 
      mutant[ index ] = @random.rand( max )
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

