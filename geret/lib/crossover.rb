
# Single point GE crossover. It assumes two parents has the form of Arrays. First, the cutting points in both parents are randomly selected, 
# then the parts after these points are swapped, forming two new offsprings.
# The positions of possible cutting points can be flexibly configured
# (which may be important for complex Mappers using more than one genome value per codon).
# Production of empty offsprings can be allowed or prohibited as well by the crossover's configuration.
# The cutting point positions in both parents can be either fixed or independent.
class Crossover
  def initialize
    @random = Kernel
    @margin = 0
    @step = 1
    @fixed = false
    @tolerance = true
  end

  # * random .. the source of randomness, used for calling "random.rand( limit )", defaulting to 'Kernel' class
  # * margin .. the minimal number of genome vector values kept from the beginning and ending of the parent vector, defaulting to 0
  # * step .. the number of genome vector values between tho possible cutting points, defaulting to 1
  # * fixed .. whether the Crossover uses the same position (Array index) for both parents' cutting points, defaulting to false
  # * tolerance .. whether the empty array is allowed as the valid offspring (if set to false, the exception is raised), defaulting to true
  attr_accessor :random, :margin, :step, :fixed, :tolerance

  # Take parent1, parent2 arguments and produce [offspring1, offspring2].
  # For instance:
  # 
  #   parent1 = [ 1,  2,  3,  4,  5,  6,  7,  8,  9,  10 ]
  #   parent2 = [ 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23 ]
  #   xover = Crossover.new
  # 
  # possible cutting points with default setting (denoted by '|' symbol):
  # 
  #   parent1 = [ | 1  |  2 |  3 |  4 |  5 |  6 |  7 |  8 |  9 | 10 | ]
  #   parent2 = [ | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | ]
  # 
  # after xover.margin = 3, the allowed cutting points are:
  #   parent1 = [ 1,   2,   3 |  4 |  5 |  6 |  7 |  8,  9, 10 ]
  #   parent2 = [ 11, 12,  13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21, 22, 23 ]
  #
  # after xover.step = 2, the allowed cutting points are:
  #   parent1 = [ 1,   2,   3 |  4,  5 |  6,  7 |  8,  9, 10 ]
  #   parent2 = [ 11, 12,  13 | 14, 15 | 16, 17 | 18,  19 | 20, 21, 22, 23 ]
  #
  # now producing the offsprings:
  #   offspring1, offspring2 = xover.crossover( parent1, parent2 )
  #   # offspring1 is [ 1, 2, 3, 4, 5, 6, 7, 16, 17, 18, 19, 20, 21, 22, 23 ] 
  #   # offspring2 is [ 11, 12, 13, 14, 15, 8, 9, 10 ]
  #
  # this is stochastic, thus: 
  #   offspring1, offspring2 = xover.crossover( parent1, parent2 )
  #   # offspring1 = [ 1, 2, 3, 18, 19, 20, 21, 22, 23 ]
  #   # offspring2 = [ 11, 12, 13, 14, 15, 16, 17, 4, 5, 6, 7, 8, 9, 10 ]
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

