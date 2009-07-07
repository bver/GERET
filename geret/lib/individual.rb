
require 'lib/shorten'

# The superclass that wraps genotype and phenotype mapping process into the single instance, typically subclassed by the real-world task individuals.
# The Individual class provides "duck-type interface" which separates a task from various algorithms.
#
class Individual

  @@shortener = Operator::Shorten.new

  # Create the new phenotype, based on the genotype, using the mapper.
  def initialize( mapper, genotype )
    @genotype = genotype
    @used_length = nil

    @phenotype = mapper.phenotype( @genotype )
    return if @phenotype.nil?

    @used_length = mapper.used_length 
  end

  # Genotype vector (array of codons) as provided by the constructor.
  attr_reader :genotype 

  # Phenotype text (string representing typically the source of the program), the result of GP mapping.
  # Phenotype attribute can be nil (if mapping process fails).
  attr_reader :phenotype 

  # The number of codons used in the mapping process (see Mapper::Base#used_length).
  attr_reader :used_length   

  # If set to true, the genome is shortened by the Shorten#shorten with the used_length argument.
  def shorten_chromozome=( shorten )
    return unless shorten
    return if @used_length.nil?
    @genotype = @@shortener.shorten( @genotype, @used_length )
  end

  # Return true if the phenotype is valid (the mapping process succeeded). 
  def valid?
    not self.phenotype.nil?
  end

end


