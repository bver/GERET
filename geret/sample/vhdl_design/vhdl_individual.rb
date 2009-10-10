
class VhdlIndividualSingleObjective < Individual

  def initialize( mapper, genotype )
    super

    @fitness = nil
  end
 
  attr_reader :fitness

  def fitness= val
    raise "FAILED:\nval: #{val}\n#{@phenotype}" if /^\d+$/ !~ val
    @fitness = val.to_i
  end

  def <=> other
    other.fitness <=> self.fitness
  end

  def stopping_condition
    @fitness >= 16
  end
 
end


class VhdlIndividualMultiObjective < VhdlIndividualSingleObjective
  include Pareto
  minimize :used_length
  maximize :fitness
end

class VhdlIndividualMOWeak < VhdlIndividualSingleObjective
  include WeakPareto
  minimize :used_length
  maximize :fitness
end

