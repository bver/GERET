
include Math

module ToyRegression

  @@engine = Evaluator.new

  Samples = 20
  Inf = (1.0/0.0) 
  def ToyRegression.f index
    point = index*2*PI/Samples
    sin(point) + point + point*point   
  end
  @@required_values = (0...Samples).map { |i| f(i) }

  attr_reader :error 

  def evaluate
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

end

class ToyIndividualSingleObjective < Individual
  include ToyRegression 

  def initialize( mapper, genotype )
    super
    evaluate
  end

  def <=> other
    self.error <=> other.error
  end
 
  def stopping_condition
    return @error < 0.01
  end
 
end

class ToyIndividualMultiObjective < ToyIndividualSingleObjective
  include Pareto
  Pareto.minimize ToyIndividualMultiObjective, :used_length
  Pareto.minimize ToyIndividualMultiObjective, :error
end

class ToyIndividualMOStrict < ToyIndividualMultiObjective
  include Pareto
  Pareto.minimize ToyIndividualMOStrict, :used_length
  Pareto.minimize ToyIndividualMOStrict, :error

  def valid?
    @error != Inf
  end

  def stopping_condition
    (@error < 0.01) and (!self.used_length.nil?) and (self.used_length < 40)
  end
end

class ToyIndividualMOWeak < ToyIndividualSingleObjective
  include WeakPareto
  Pareto.minimize ToyIndividualMOWeak, :used_length
  Pareto.minimize ToyIndividualMOWeak, :error

  def stopping_condition
    (@error < 0.01) and (!self.used_length.nil?) and (self.used_length < 40)
  end
end


