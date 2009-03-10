
class Crossover
  def initialize
    @random = Kernel
    @margin = 0
    @step = 1
  end

  attr_accessor :random, :margin, :step

  def crossover( parent1, parent2 )
    pts1 = []
    @margin.step( parent1.size - @margin, @step ) { |i| pts1.push i }
    pts2 = []
    @margin.step( parent2.size - @margin, @step ) { |i| pts2.push i }
    return parent1.clone, parent2.clone if pts1.empty? or pts2.empty?
  
    pt1 = pts1.at @random.rand(pts1.size)
    pt2 = pts2.at @random.rand(pts2.size)

    offs1 = parent1[0...pt1].clone
    offs1 = offs1.concat parent2[pt2...parent2.size]
    offs2 = parent2[0...pt2].clone   
    offs2 = offs2.concat parent1[pt1...parent1.size]
    return offs1, offs2
  end
end

