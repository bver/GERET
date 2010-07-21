
require 'lib/codon_mod'

module Mapper
 
  class CodonBucket < CodonMod
  
    def initialize
      super
      @bucket = nil     
    end

    attr_reader :bucket

    def grammar= gram
      @bucket = {}
      max_allele = 1
      gram.symbols.each do |sym|
        alts = gram[sym] 
        @bucket[sym] = max_allele
        max_allele *= alts.size
      end
    end   

    def interpret( numof_choices, codon, symbol=nil )
      codon = codon.divmod( @bucket[symbol] ).first unless @bucket.nil? or symbol.nil?
      super( numof_choices, codon )
    end

    def generate( numof_choices, index, symbol=nil )
      codon = super( numof_choices, index )
      return ( @bucket.nil? or symbol.nil? ) ? codon : ( codon * @bucket[symbol] )
    end



  end

end


