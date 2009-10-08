
class FclIndividualSingleObjective < Individual

  def initialize( mapper, genotype )
    super

    @error = nil
  end
 
  attr_reader :error

  def error= val
    raise "FAILED:\nval: #{val}\n#{@phenotype}" if /^\d+\.\d+$/ !~ val
    @error = val.to_f
  end

  def <=> other
    self.error <=> other.error
  end
 
  def stopping_condition
    return @error < 0.009
  end
 
end


