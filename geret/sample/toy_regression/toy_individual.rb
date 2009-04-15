
include Math

class SingleObjectiveIndividual

  @@engine = Evaluator.new

  def initialize( mapper, genotype=nil )
    @mapper = mapper
    @genotype = genotype
    @phenotype = nil
    @used_length = nil  
    @error = nil
    @init_magnitude = 10
  end

  attr_accessor :init_magnitude, :init_length 

  def genotype
    @genotype = RandomInit.new( @init_magnitude ).init( @init_length ) if @genotype.nil?
    @genotype
  end

  def phenotype
    return @phenotype unless @phenotype.nil?

    @error = nil   
    @phenotype = @mapper.phenotype( self.genotype )   
    @used_length = @mapper.used_length 

    return @phenotype
  end

  def used_length
    self.phenotype if @phenotype.nil?
    @used_length
  end

  def <=> other
    self.error <=> other.error
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

    return Inf if self.phenotype.nil?
    @@engine.code = self.phenotype

    @error = 0.0
    @@required_values.each_with_index do |required,index|
      point = index*2*PI/Samples
      value = @@engine.run( 'x' => point )
      return Inf if value.nil?
      @error += ( value - required ).abs
    end

    @error
  end

  def stopping_condition
    return self.error < 0.01
  end

end

