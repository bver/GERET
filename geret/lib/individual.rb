
require 'lib/shorten'

class Individual

  @@shortener = Shorten.new

  def initialize( mapper, genotype )
    @genotype = genotype
    @used_length = nil

    @phenotype = mapper.phenotype( @genotype )
    return if @phenotype.nil?

    @used_length = mapper.used_length 
  end

  attr_reader :genotype, :phenotype, :used_length 

  def shorten_chromozome=( shorten )
    return unless shorten
    return if @used_length.nil?
    @genotype = @@shortener.shorten( @genotype, @used_length )
  end

  def valid?
    not self.phenotype.nil?
  end

end


