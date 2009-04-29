
$: << 'sample/santa_fe_ant_trail'
require 'ant'

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
  Pareto.minimize AntIndividualMultiObjective, :used_length
  Pareto.maximize AntIndividualMultiObjective, :fitness
end
