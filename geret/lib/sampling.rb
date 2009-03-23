
require 'lib/roulette'

module Selection

  class Sampling < Roulette
  
    def initialize proportional_by
      super
    end

    def select( population, how_much )
      raise "Sampling: cannot select more than population.size" if how_much > population.size
      sum,wheel = wheel_core population

      step = sum.to_f/how_much
      ballot = step * @random.rand 

      width = 0.0
      winners = []
      wheel.each_with_index do |slot,index|
        width += slot.width
        next if ballot > width
        winners.push slot.original   
        ballot += step
      end

      winners
    end
  
  end

end # Selection
