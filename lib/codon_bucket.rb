
require 'lib/codon_mod'

module Mapper

  # "Bucket rule" codon representation:
  #
  #   index_of_choice = (codon / bucket) mod num_of_choices 
  #
  # where 
  #   bucket(symbolX) = num_of_choices[symbol0] * num_of_choices[symbol1] ... * num_of_choices[symbolX-1] 
  #
  # This grammar-dependent representation modifies the standard GE representation implemented 
  # by Mapper::CodonMod.
  # With this rule, every codon encodes a unique set of producion rules, each from one nonterminal.
  # See: 
  #  http://books.google.com/books?id=eCbu4GwRLusC&lpg=PA123&ots=hUc3zvqYIh&lr&pg=PA123#v=onepage&q&f=false 
  #
  class CodonBucket < CodonMod
  
    # Initialise a codon representation.
    # bit_size is the number of bits per one codon.
    def initialize
      super
      @bucket = nil    
      @max_closure = nil
    end

    # Closures hash. The element c.bucket['s'] represents a modifier for all codons encoding a symbol 's'.
    attr_reader :bucket

    # Maximal value of the codon modifier.
    attr_reader :max_closure

    # Set the current grammar for codon representation.
    def grammar= gram
      @bucket = {}
      @max_closure = 1
      gram.symbols.each do |sym|
        alts = gram[sym] 
        @bucket[sym] = @max_closure
        @max_closure *= alts.size
      end
    end   

    # Interpret the codon given a number of choices and a symbol ( (c/s) mod n )   
    def interpret( numof_choices, codon, symbol=nil )
      codon = codon.divmod( @bucket[symbol] ).first unless @bucket.nil? or symbol.nil?
      super( numof_choices, codon )
    end

    # Create the codon from the index of the choice, number of choices and a symbol.
    # See CodonMod#generate for details.
    def generate( numof_choices, index, symbol=nil )
      codon = super( numof_choices, index )
      ( @bucket.nil? or symbol.nil? ) ? codon : ( codon * @bucket[symbol] )
    end

    # Mutate a single bit in the source codon, return the mutated codon.
    def mutate_bit codon
      return super if @bucket.nil?
      codon ^ (2 ** @random.rand( @bit_size + @max_closure.to_s(2).size-1 ))
    end
   
    # Generate a valid random codon
    def rand_gen
      return super if @bucket.nil?     
      @random.rand( @card * @max_closure )
    end
   
    # Return true if the codon is valid
    def valid_codon? codon
      return super if @bucket.nil?
      codon >= 0 and codon < @card*@max_closure
    end

  end

end


