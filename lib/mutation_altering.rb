
module Operator

  # Common functionality for MutationBitNodal, MutationBitStructural, MutationNodal and 
  # MutationStructural classes.  
  #
  class MutationAlteringCore

    # See a subclass description.
    def initialize( grammar )
      @grammar = grammar
      @random = Kernel
      @offset = 0
    end
   
    # See a subclass description.
    def mutation( orig, track )
      mutant = orig.clone
      filtered_track = track.find_all { |node| @grammar[ node.symbol ].sn_altering == filter }
      return mutant if filtered_track.empty?
      where = @random.rand( filtered_track.size )
      index = ( filtered_track[where].from + @offset ).divmod( mutant.size ).last
      mutant[ index ] = get_codon_value( mutant, index )
      mutant
    end

    # Offset which is added to the index of the mutated codon's position.
    # This is useful for Mapper::*Locus mappers where the odd codons encode a location choices and 
    # even codons encode rule choices.
    attr_accessor :offset
  end

  # Common functionality for MutationBitNodal and MutationBitStructural classes. 
  # 
  # Select the random (nodal/structural filtered) position within the orig vector and mutate it.
  # The resultant value (of a mutated codon) is bit-mutated by self.codon.mutate_bit method.
  # Return the mutated copy of the orig. genotype.
  # track argument is the hint (symbols attached to positions) obtained from Mapper::Base#track_support 
  #
  class MutationBitAltering < MutationAlteringCore 

    # Create the mutation operator.
    # grammar is the valid grammar for distinguishing :structural and :nodal symbols
    def initialize( grammar )
      super
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
   
    protected

    def get_codon_value( mutant, index )  
      @codon.mutate_bit( mutant.at(index) ) 
    end
  
  end

  # Structural bit-level mutation (see http://portal.acm.org/citation.cfm?id=1570215).
  # It assumes the source genotype has the form of the Array of numbers.
  # Select codons with Token#sn_altering == :structural for mutation.
  # Structural change means the length of genotype->phenotype transformation process CAN change for mutated genotype.
  #
  class MutationBitStructural < MutationBitAltering
    protected
    def filter
      :structural 
    end
  end

  # Nodal bit-level mutation (see http://portal.acm.org/citation.cfm?id=1570215).
  # It assumes the source genotype has the form of the Array of numbers.
  # Select codons with Token#sn_altering == :nodal for mutation.
  # Nodal change means the length of genotype->phenotype transformation process CANNOT change for mutated genotype. 
  #
  class MutationBitNodal < MutationBitAltering
    protected
    def filter
      :nodal
    end
  end


  # Common functionality for MutationNodal and MutationStructural classes. 
  # Select the random (nodal/structural filtered) position within the orig vector and mutate it.
  # The resultant value (of a mutated codon) is a random number in the range 0..magnitude.
  # Return the mutated copy of the orig. genotype.
  # track argument is the hint (symbols atteched to positions) obtained from Mapper::Base#track_support 
  #
  class MutationAltering < MutationAlteringCore 

    # Create the mutation operator.
    # grammar is the valid grammar for distinguishing :structural and :nodal symbols
    # magnitude is the initial value of the MutationAltering#magnitude attribute
    def initialize( grammar, magnitude=nil )
      super(grammar)
      @magnitude = magnitude
    end

    # The source of randomness, used for calling "random.rand( limit )", defaulting to 'Kernel' class.
    attr_accessor :random
   
    # The maximal possible value of the mutaton plus 1. If not specified, the maximal value over the original 
    # genotype values is used.
    attr_accessor :magnitude

    protected

    def get_codon_value( mutant, index ) 
      max = @magnitude.nil? ? mutant.max+1 : @magnitude
      @random.rand( max )
    end
  
  end

  # Structural codon-level mutation (see http://portal.acm.org/citation.cfm?id=1570215).
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

  # Nodal codon-level mutation (see http://portal.acm.org/citation.cfm?id=1570215).
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

