
# Cut off the unused tail of the chromozome.
# This operator is typically applied after the GE mapping (see Mapping::Base) when there is 
# an information about the numbers of codons used for the phenotype creation.
# There are two modes of the operation: stochastic and deterministic.
#
class Shorten

  # Use the default Kernel.rand and deterministic mode.
  def initialize
    @random = Kernel
    @stochastic = false
  end
  
  # the source of randomness, used for calling "random.rand( limit )", defaulting to 'Kernel' class.
  attr_accessor :random
 
  # The mode of the operation:
  #    true .. the genotype is shortened at the precisely specified cutting index.
  #    false .. the genotype is shortened at the random point after the specified index.
  attr_accessor :stochastic

  # Shorten the genotype gen, specifying the point max.
  # See stochastic attribute for meaning of the argument max.
  def shorten( gen, max )
    return gen.clone if gen.size <= max
    point = @stochastic ? (@random.rand( gen.size+1-max ) + max) : max
    gen.clone[0...point]
  end

end

