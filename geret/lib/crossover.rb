
class Crossover
  def initialize
    @random = Kernel
    @margin = 0
    @step = 1
    @fixed = false
    @tolerance = true
  end

  attr_accessor :random, :margin, :step, :fixed, :tolerance

  def crossover( parent1, parent2 )
    pts1 = []
    @margin.step( parent1.size - @margin, @step ) { |i| pts1.push i }
    pts2 = []
    @margin.step( parent2.size - @margin, @step ) { |i| pts2.push i }

    if pts1.empty? or pts2.empty? 
      return parent1.clone, parent2.clone if @tolerance #fallback 
      raise "Crossover: operand(s) too short"
    end
  
    if @fixed 
      if parent1.size < parent2.size
        pt1 = pt2 = pts1.at( @random.rand(pts1.size) )
      else
        pt1 = pt2 = pts2.at( @random.rand(pts2.size) )
      end
    else
      pt1 = pts1.at @random.rand(pts1.size)
      pt2 = pts2.at @random.rand(pts2.size)
    end

    offs1 = parent1[0...pt1].clone
    offs1 = offs1.concat parent2[pt2...parent2.size]
    offs2 = parent2[0...pt2].clone   
    offs2 = offs2.concat parent1[pt1...parent1.size]
    return offs1, offs2
  end
end

