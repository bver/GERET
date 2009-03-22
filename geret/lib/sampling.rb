
require 'lib/roulette'

module Selection

  class Sampling < Roulette
  
    def initialize proportional_by
      super
    end

    def select( population, how_much )
      sum,wheel = wheel_core population

      step = sum.to_f/how_much
      ballot = step * @random.rand 

      sum = 0.0
      winners = []
      index = 0
      while winners.size < how_much
        slot = wheel[index]
        sum += slot.width
        if sum > ballot
          winners.push slot.original         
          ballot += step
        end
        index += 1
      end

      winners
    end
  
  end

end # Selection

