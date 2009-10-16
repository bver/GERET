
include Math

module ToyRegression

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

    error = 0.0
    begin
      @@required_values.each_with_index do |required,index|
        point = index*2*PI/Samples
        value = eval( "x = #{point};" + @phenotype )
        error += ( value - required ).abs
      end
    rescue
      return
    end
    
    return if error.nan?
    @error = error
  end

end

class ToyIndividualSingleObjective < Individual
  include ToyRegression 

  def initialize( mapper, genotype )
    super
    @complexity = mapper.complexity
    evaluate
  end

  attr_reader :complexity

  def <=> other
    self.error <=> other.error
  end
 
  def stopping_condition
    return @error < 0.01
  end
 
end

class ToyIndividualMultiObjective < ToyIndividualSingleObjective
  include Pareto
  minimize :complexity
  minimize :error
end

class ToyIndividualMOStrict < ToyIndividualSingleObjective
  include Pareto
  minimize :complexity
  minimize :error

  def valid?
    @error != Inf
  end

  def stopping_condition
    (@error < 0.01) and (!self.used_length.nil?) and (self.used_length < 40)
  end
end

class ToyIndividualMOWeak < ToyIndividualSingleObjective
  include WeakPareto
  minimize :complexity
  minimize :error

  def stopping_condition
    (@error < 0.01) and (!self.used_length.nil?) and (self.used_length < 40)
  end
end


