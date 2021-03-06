
require 'lib/codon_mod'

module Mapper

  # Gray-coded representation. This representation modifies the standard GE mapping with
  # the Gray transcription.
  # 
  # See http://wwwilson.wordpress.com/files/2009/01/search-neutral-evol-and-mapping.pdf 
  #
  class CodonGray < CodonMod

    # Initialise a codon representation.
    # bits is the number of bits per one codon.
    def initialize( bits=8 )
      super
      self.bit_size = bits
    end
 
    # Set the number of bits per codon.
    def bit_size= bit_size
      super
      x = ['0','1'] 
      (bit_size-1).times do
        y = (x.map { |i| '0'+i }).concat( x.reverse.map { |i| '1'+i } )
        x=y 
      end

      @gray = x.map { |i| i.to_i(2) }
      @reverse = []
      @gray.each_with_index { |g,i| @reverse[g] = i } 
    end
 
    # Interpret the codon given a number of choices.
    # See CodonMod#interpret. 
    def interpret( numof_choices, codon, dummy=nil )
      super( numof_choices, @reverse[codon] )
    end

    # Create the codon from the index of the choice and number of choices.
    # See CodonMod#generate.
    def generate( numof_choices, index, dummy=nil )
      @gray[super]
    end

    # Read a raw codon value
    def raw_read codon
      @reverse[codon]
    end

  end

end

