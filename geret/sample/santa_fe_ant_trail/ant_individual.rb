
$: << 'sample/santa_fe_ant_trail'
require 'ant'

class AntIndividualSingleObjective < Individual

  def initialize( mapper, genotype )

    super

    ant = Ant.new
    400.times { eval @phenotype }
    @fitness = ant.consumed_food
    
  end

  attr_reader :fitness

  def <=> other
    other.fitness <=> self.fitness
  end

end

