
module Operator

  # Classic two-point crossover. It assumes two parents has the form of Arrays. 
  # First, the cutting points in both parents are randomly selected, 
  # then the middle parts are swapped, forming two new offsprings.
  #
  # Note the valid cutting point can be placed before the first element or after the last element of the array.
  #
  class CrossoverTwoPoints

    # Create a new two-point crossover operator.
    def initialize
      @random = Kernel
    end

    # The source of randomness, used for calling "random.rand( limit )", defaulting to 'Kernel' class.
    attr_accessor :random

    # Take parent1, parent2 arguments and produce [offspring1, offspring2].
    # For instance:
    # 
    #   parent1 = [ 1,  2,  3,  4,  5,  6,  7,  8,  9,  10 ]
    #   parent2 = [ 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23 ]
    #   xover = CrossoverTwoPoints.new
    # 
    # now producing the offsprings:
    #   offspring1, offspring2 = xover.crossover( parent1, parent2 )
    # offspring1 is [ 1, 2, 3, 4, 5,   16, 17, 18,   8, 9, 10 ] 
    # offspring2 is [ 11, 12, 13, 14,   6, 7,   15, 19, 20, 21, 22, 23 ]
    #
    # This is a stochastic process, thus repeating: 
    #   offspring1, offspring2 = xover.crossover( parent1, parent2 )
    # produces:  
    # offspring1 is [ 1, 2,   20 ] 
    # offspring2 is [ 11, 12, 13, 14, 15, 16, 17, 18, 19,    3,  4,  5,  6,  7,  8,  9,  10,    21, 22, 23  ]
    #    
    def crossover( parent1, parent2, dummy1=nil, dummy2=nil )

      pts1 = []
      0.step( parent1.size, 1 ) { |i| pts1.push i }
      pts2 = []
      0.step( parent2.size, 1 ) { |i| pts2.push i }

      return parent1.clone, parent2.clone if pts1.size < 2 or pts2.size < 2
        
      pt11 = pts1.at @random.rand(pts1.size)
      pt12 = pts1.at @random.rand(pts1.size)     
      pt11,pt12 = [pt12,pt11] if pt11 > pt12

      pt21 = pts2.at @random.rand(pts2.size)
      pt22 = pts2.at @random.rand(pts2.size)     
      pt21,pt22 = [pt22,pt21] if pt21 > pt22   

      offs1 = parent1[0...pt11].clone
      offs1 = offs1.concat parent2[pt21...pt22]
      offs1 = offs1.concat parent1[pt12...parent1.size]

      offs2 = parent2[0...pt21].clone
      offs2 = offs2.concat parent1[pt11...pt12]
      offs2 = offs2.concat parent2[pt22...parent2.size]

      return offs1, offs2
     
    end

  end

end

