
include Math

class MappingIndividual

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

class ToyIndividual < MappingIndividual

  @@engine = Evaluator.new

  Samples = 20
  Inf = (1.0/0.0) 
  def ToyIndividual.f index
    point = index*2*PI/Samples
    sin(point) + point + point*point   
  end
  @@required_values = (0...Samples).map { |i| f(i) }

  attr_reader :error 

  def initialize( mapper, genotype )
    super
    @error = Inf

    return if @phenotype.nil? 
    @@engine.code = @phenotype

    error = 0.0
    @@required_values.each_with_index do |required,index|
      point = index*2*PI/Samples
      value = @@engine.run( 'x' => point )
      return if value.nil?
      error += ( value - required ).abs
    end
    
    return if error.nan?
    @error = error
  end

  def <=> other
    self.error <=> other.error
  end
 
  def stopping_condition
    return @error < 0.01
  end

#  def valid?
#    self.error.infinite?.nil?
#  end
 
end

