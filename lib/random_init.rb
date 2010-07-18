
module Operator

# Generate the random genotype of the specified size.
#
# See also Mapper::Generator for description of the Sensible Initialisation.
#
class RandomInit

  def initialize
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
 
  # Generate the genotype (chromozome) of the given length.
  def init length
    gen = []
    length.times { gen << @codon.rand_gen }
    gen
  end

end

end # Operator
