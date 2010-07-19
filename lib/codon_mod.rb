
module Mapper

  # Standard codon representation in GE:
  #
  #   index_of_choice = codon mod num_of_choices
  #
  class CodonMod

    # Initialise a codon representation.
    # bit_size is the number of bits per one codon.
    def initialize( bit_size=8 )
      self.bit_size= bit_size
      @random = Kernel
    end

    # Set the number of bits per codon.
    def bit_size= bit_size
      @bit_size = bit_size
      @card = 2**bit_size
    end

    # Interpret the codon given a number of choices ( c mod n )
    def interpret( numof_choices, codon )
      codon.divmod(numof_choices).last
    end

    # Create the codon from the index of the choice and number of choices
    # index has to be the number from the interval 0 .. numof_choices-1 
    # Resultant codon is stochastically produced number which,
    # when subjected to the modulo operation, produces index, ie:
    #
    #   index = codon mod numof_choices 
    # 
    # See:
    # http://www-dept.cs.ucl.ac.uk/staff/W.Langdon/ftp/papers/azad_thesis.ps.gz 
    # Chapter 7 Sensible Initialisation, page 132, 'unmod' operation.
    #
    def generate( numof_choices, index )
      raise "CodonMod: cannot accomodate #{numof_choices} choices in #{@bit_size}-bit codon" if numof_choices > @card
      raise "CodonMod: index (#{index}) must be lower than numof choices (#{numof_choices})" if index >= numof_choices
      return index if numof_choices == 0
      index + numof_choices * @random.rand( @card/numof_choices )
    end

    # Generate a valid random codon
    def rand_gen
      @random.rand @card
    end

    # Mutate a single bit in the source codon, return the mutated codon.
    def mutate_bit codon
      codon ^ (2 ** @random.rand( @bit_size ))
    end

    # Return true if the codon is valid
    def valid_codon? codon
      codon >= 0 and codon < @card
    end

    # The source of randomness, used for calling "random.rand( limit )", defaulting to 'Kernel' class.
    attr_accessor :random    
  
    # The number of bits per codon. 
    attr_reader :bit_size
  end

end

