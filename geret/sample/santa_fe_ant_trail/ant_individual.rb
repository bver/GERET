
$: << 'sample/santa_fe_ant_trail'
require 'ant'

class AntIndividualSingleObjectiveTcc < Individual

  def initialize( mapper, genotype )
    super

    @phenotype += "\nMARKER\n" unless @phenotype.nil?

    @fitness = nil
  end
 
  attr_reader :fitness

  def fitness= val
    @fitness = val.to_i
  end

  def <=> other
    other.fitness <=> self.fitness
  end

  def stopping_condition
    @fitness >= 89
  end
 
end


class AntIndividualSingleObjective < Individual

  def initialize( mapper, genotype )

    super

    @fitness = if @phenotype.nil?
      0
    else
      ant = Ant.new
      eval @phenotype while ant.steps < Ant::MaxSteps
      ant.consumed_food
    end
    
  end

  attr_reader :fitness

  def <=> other
    other.fitness <=> self.fitness
  end

  def stopping_condition
    @fitness >= 89
  end
 
end

class AntIndividualMultiObjective < AntIndividualSingleObjective
  include Pareto
  minimize :used_length
  maximize :fitness
end

class AntIndividualMOWeak < AntIndividualSingleObjective
  include WeakPareto
  minimize :used_length
  maximize :fitness
end

