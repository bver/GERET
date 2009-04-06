include Math

class ToyIndividual

  Samples = 20
  Inf = (1.0/0.0) 
  def ToyIndividual.f index
    point = index*2*PI/Samples
    sin(point) + point + point*point   
  end

  @@required_values = (0...Samples).map { |i| f(i) }

  @@engine = Evaluator.new

  def initialize( mapper, genotype=nil )
    @mapper = mapper
    @genotype = genotype
    @phenotype = nil
    @error = nil
    @init_magnitude = 10
  end

  attr_accessor :random_init_magnitude

  def genotype
    @genotype = RandomInit.new( @init_magnitude ).init if @genotype.nil?
    @genotype
  end

  def phenotype
    return @phenotype unless @phenotype.nil?

    @error = nil   
    return @phenotype = @mapper.phenotype( self.genotype )
  end

  def error
    return @error unless @error.nil?

    return Inf if self.phenotype.nil?
    @@engine.code = self.phenotype

    @error = 0.0
    @@required_values.each_with_index do |required,index| 
      value = @@engine.run( :x => index ).first
      @error += abs( value - required )
    end
  end

  def <=> other
    self.error <=> other.error
  end

end

