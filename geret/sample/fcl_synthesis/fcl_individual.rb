
class FclIndividualSingleObjective < Individual

  def initialize( mapper, genotype )
    super

    @error = nil
  end
 
  attr_accessor :error

  def <=> other
    self.error <=> other.error
  end
 
  def stopping_condition
    return @error < 0.009
  end
 
end


