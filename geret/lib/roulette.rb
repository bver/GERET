
module Selection
  class Roulette
    Slot = Struct.new( 'Slot', :original, :width )

    def initialize proportionalBy
      @prop = if proportionalBy.kind_of? Proc
                proportionalBy
              else
                proc { |individual| individual.send(proportionalBy) }
              end
      @random = Kernel
    end

    attr_accessor :random

    def select population
      sum,wheel = wheelCore population

      ballot = sum * @random.rand   

      sum = 0.0
      wheel.each do |slot|
        sum += slot.width
        return slot.original if sum > ballot
      end
     
      return wheel.last.original
    end

    protected

    def wheelCore population
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

