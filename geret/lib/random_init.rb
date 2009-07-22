
module Operator

# Generate the random genotype of the specified size.
# The maximal values of codons can be controlled by the settings.
#
# See also Mapper::Generator for description of the Sensible Initialisation.
#
class RandomInit

  # Specify the magnitude or the magnitude array.
  # There are two modes of the magnitude setting:
  # 1. the magnitude value is the number. Then "random.rand(magnitude)" is used for generating all genotype values:
  #   
  #   init = RandomInit.new 10
  #   init.init(4) # produces: [3, 0, 8, 5]
  #   
  # 2. the magnitude is the array (vector) of the magnitude values representing limits for random generator. 
  # For the first codon the magnitude[0] is used, for the second codon the magnitude[1] is used, etc. 
  # When the end of the magnitude vector is reached, the wrapping occurs and the magnitude[0] is 
  # used for magnitude.size-th codon. For instance:
  #   
  #   init = RandomInit.new [10, 2, 1000]
  #   init.init(6) # produces [8, 0, 892,  5, 1, 403]
  #   
  def initialize magnitude
    @random = Kernel
    if magnitude.kind_of? Array
      @magnitude = magnitude
    else
      @magnitude = [magnitude]
    end
  end

  # The source of randomness, used for calling "random.rand( limit )", defaulting to 'Kernel' class.
  attr_accessor :random

  # The maximal possible value(s) of the codon. See RandomInit#initialize.
  attr_accessor :magnitude

  # Generate the genotype (chromozome) of the given length.
  # If the array of magnitude values is used, the length has to be the multiple of magnitude.size 
  # (otherwise it is cropped to the nearest lesser one).
  def init length
    gen = []
    length.divmod(@magnitude.size).first.times do
      gen.concat @magnitude.map {|m| @random.rand(m) }
    end
    gen
  end

end

end # Operator
