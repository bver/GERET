
module Mapper

  class CodonMod

    def initialize( bit_size=8 )
      self.bit_size= bit_size
      @random = Kernel
    end

    def bit_size= bit_size
      @bit_size = bit_size
      @card = 2**bit_size
    end

    def interpret( numof_choices, codon )
      codon.divmod(numof_choices).last
    end

    def generate( numof_choices, index )
      raise "CodonMod: cannot accomodate #{numof_choices} choices in #{@bit_size}-bit codon" if numof_choices > @card
      raise "CodonMod: index (#{index}) must be lower than numof choices (#{numof_choices})" if index >= numof_choices
      return index if numof_choices == 0
      index + numof_choices * @random.rand( @card/numof_choices )
    end

    def rand_gen
      @random.rand @card
    end

    def mutate_bit codon
      codon ^ (2 ** @random.rand( @bit_size ))
    end

    def valid_codon? codon
      codon >= 0 and codon < @card
    end

    # The source of randomness, used for calling "random.rand( limit )", defaulting to 'Kernel' class.
    attr_accessor :random    
  
    attr_reader :bit_size
  end

end

