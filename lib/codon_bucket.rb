
require 'lib/codon_mod'

module Mapper
 
  class CodonBucket < CodonMod
  
    def initialize
      super
      @bucket = nil    
      @max_closure = nil
    end

    attr_reader :bucket

    attr_reader :max_closure

    def grammar= gram
      @bucket = {}
      @max_closure = 1
      gram.symbols.each do |sym|
        alts = gram[sym] 
        @bucket[sym] = @max_closure
        @max_closure *= alts.size
      end
    end   

    def interpret( numof_choices, codon, symbol=nil )
      codon = codon.divmod( @bucket[symbol] ).first unless @bucket.nil? or symbol.nil?
      super( numof_choices, codon )
    end

    def generate( numof_choices, index, symbol=nil )
      codon = super( numof_choices, index )
      ( @bucket.nil? or symbol.nil? ) ? codon : ( codon * @bucket[symbol] )
    end

    def mutate_bit codon
      return super if @bucket.nil?
      codon ^ (2 ** @random.rand( @bit_size + @max_closure.to_s(2).size-1 ))
    end
   
    def rand_gen
      return super if @bucket.nil?     
      @random.rand( @card * @max_closure )
    end
   
    def valid_codon? codon
      return super if @bucket.nil?
      codon >= 0 and codon < @card*@max_closure
    end

  end

end


