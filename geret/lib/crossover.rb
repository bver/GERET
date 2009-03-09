
class Crossover
  def initialize
    @random = Kernel
    @margin = 0
  end

  attr_accessor :random, :margin

  def crossover( parent1, parent2 )
    return parent1.clone, parent2.clone if parent1.size < 2*@margin or parent2.size < 2*@margin

    pt1 = @random.rand(parent1.size+1 - 2*@margin) + @margin 
    pt2 = @random.rand(parent2.size+1 - 2*@margin) + @margin

    offs1 = parent1[0...pt1].clone
    offs1 = offs1.concat parent2[pt2...parent2.size]
    offs2 = parent2[0...pt2].clone   
    offs2 = offs2.concat parent1[pt1...parent1.size]
    return offs1, offs2
  end
end

