
class Roulette
  Slot = Struct.new( 'WheelSlot', :original, :width )

  def initialize proportionalBy
    @prop = proportionalBy
    @random = Kernel
  end

  attr_accessor :random

  def select population
     raise "Roulette: cannot select from empty population" if population.empty?

     wheel = []
     sum = 0.0
     population.each do |individual| 
       width = individual.send(@prop).to_f
       raise  "Roulette: cannot use negative slot width" if width < 0.0
       wheel.push Slot.new( individual, width ) 
       sum += width
     end

     ballot = sum * @random.rand   
     sum = 0.0
     wheel.each do |slot|
       sum += slot.width
       return slot.original if sum > ballot
     end
     
     return wheel.last.original
  end

end

