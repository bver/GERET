
module Selection

  class Roulette
  
    Slot = Struct.new( 'Slot', :original, :width )

    def initialize proportional_by
      @prop = if proportional_by.kind_of? Proc
                proportional_by
              else
                proc { |individual| individual.send(proportional_by) }
              end
      @random = Kernel
    end

    attr_accessor :random

    def select population
      sum,wheel = wheel_core population

      ballot = sum * @random.rand   

      sum = 0.0
      wheel.each do |slot|
        sum += slot.width
        return slot.original if sum > ballot
      end
     
      return wheel.last.original
    end

    protected

    def wheel_core population
      raise "Roulette: cannot select from an empty population" if population.empty?

      wheel = []
      sum = 0.0
      population.each do |individual| 
        width = @prop.call(individual).to_f
        raise  "Roulette: cannot use a negative slot width" if width < 0.0
        wheel.push Slot.new( individual, width ) 
        sum += width
      end

      wheel.sort! { |a,b| b.width <=> a.width }

      wheel = []
      sum = 0.0
      population.each do |individual| 
        width = @prop.call(individual).to_f
        raise  "Roulette: cannot use negative slot width" if width < 0.0
        wheel.push Slot.new( individual, width ) 
        sum += width
      end

      return sum, wheel.sort { |a,b| b.width <=> a.width }
    end

  end

end # Selection

