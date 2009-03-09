
class GenOps
  def initialize
    @random = Kernel
  end

  attr_accessor :random

  def crossover( parent1, parent2 )
    pt1 = @random.rand(parent1.size+1)
    pt2 = @random.rand(parent2.size+1)

    offs1 = parent1[0...pt1].clone
    offs1 = offs1.concat parent2[pt2...parent2.size]
    offs2 = parent2[0...pt2].clone   
    offs2 = offs2.concat parent1[pt1...parent2.size]
    return offs1, offs2
  end
end

