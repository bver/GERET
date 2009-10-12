
class AntIndividualSingleObjectiveTcc < Individual

  def initialize( mapper, genotype )
    super

    @phenotype += "\nMARKER\n" unless @phenotype.nil?

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
    @fitness >= 89
  end
 
end

class AntIndividualMultiObjectiveTcc < AntIndividualSingleObjectiveTcc
  include Pareto
  minimize :used_length
  maximize :fitness
end



