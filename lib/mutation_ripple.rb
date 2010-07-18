
require 'lib/codon_mod'

module Operator

# Simple mutation. It assumes the source genotype has the form of the Array of numbers.
#
class MutationRipple

  # Create the mutation operator with default settings.
  def initialize dummy=nil
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
 
  # Select the random position within the orig vector and mutate it.
  # The resultant value (of a mutated codon) is a random number in the range 0..magnitude.
  # Return the mutated copy of the orig. genotype.
  def mutation( orig, dummy=nil )
    mutant = orig.clone
    where = @random.rand( orig.size )
    mutant[ where ] = @codon.mutate_bit( mutant.at(where) )
    mutant
  end

end

end # Operator
