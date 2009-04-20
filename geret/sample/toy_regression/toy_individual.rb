
include Math

class SingleObjectiveIndividual

  @@engine = Evaluator.new

  @@shortener = Shorten.new

  def initialize( mapper, genotype )
    @genotype = genotype
    map_phenotype mapper
    @error = nil
  end

  attr_reader :used_length, :genotype, :phenotype 

  def map_phenotype mapper  
    @used_length = nil
    @phenotype = mapper.phenotype( @genotype )
    return if @phenotype.nil?

    @used_length = mapper.used_length 
    @genotype = @@shortener.shorten( @genotype, @used_length ) 
  end

  def <=> other
    self.error <=> other.error
  end

  def valid?
    #not self.phenotype.empty?
    self.error.infinite?.nil?
  end

end

class ToyIndividual < SingleObjectiveIndividual

  Samples = 20
  Inf = (1.0/0.0) 
  def ToyIndividual.f index
    point = index*2*PI/Samples
    sin(point) + point + point*point   
  end

  @@required_values = (0...Samples).map { |i| f(i) }

  def initialize( mapper, genotype=nil )
    super
  end

  def error
    return @error unless @error.nil?
    @error = Inf

    return Inf if @phenotype.nil? 
    @@engine.code = @phenotype

    error = 0.0
    @@required_values.each_with_index do |required,index|
      point = index*2*PI/Samples
      value = @@engine.run( 'x' => point )
      return Inf if value.nil?
      error += ( value - required ).abs
    end
    
    return Inf if error.nan?
    @error = error
  end

  def stopping_condition
    return self.error < 0.01
  end

end

