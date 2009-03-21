
class Roulette
  Slot = Struct.new( 'WheelSlot', :original, :width )

  def initialize proportionalBy
    @prop = proportionalBy
    @random = Kernel
  end

  attr_accessor :random

  def select population
     wheel = []
     sum = 0.0
     population.each do |individual| 
       wheel.push Slot.new( individual, individual.send(@prop) ) 
       sum += wheel.last.width
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

