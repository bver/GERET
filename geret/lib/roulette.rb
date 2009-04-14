
require 'lib/select_more'

module Selection

  class Roulette
    include SelectMore

    Slot = Struct.new( 'Slot', :original, :width )

    def initialize proportional_by=nil, &block
      @prop = if proportional_by.nil?
                block
              else
                proc { |individual| individual.send(proportional_by) }
              end
      @proportional_by = proportional_by     
      @random = Kernel
    end

    attr_accessor :random
    attr_reader :proportional_by

    def select_one population
      sum,wheel = wheel_core population

      ballot = sum * @random.rand   

      sum = 0.0
      wheel.each do |slot|
        sum += slot.width
        return slot.original if sum > ballot
      end
     
      return wheel.last.original
    end

    def proportional_by= proportional_by
      @prop = proc { |individual| individual.send(proportional_by) }
      @proportional_by = proportional_by     
    end

    protected

    def wheel_core population
      raise "Roulette: cannot select from an empty population" if population.empty?

      sum = 0.0
      wheel = population.map do |individual| 
        width = @prop.call(individual).to_f
        raise  "Roulette: cannot use a negative slot width" if width < 0.0
        sum += width
        Slot.new( individual, width ) 
      end

      return sum, wheel.sort { |a,b| b.width <=> a.width }
    end

  end

end # Selection

