
require 'lib/roulette'

module Selection

  class Sampling < Roulette
  
    def initialize( proportional_by=nil, &block )
      super
    end

    def select( how_much, population=self.population )
      raise "Sampling: cannot select from an empty population" if population.empty?
      raise "Sampling: cannot select more than population.size" if how_much > population.size
      return [] if how_much == 0

      @sum,@wheel = wheel_core population if @wheel.nil? or population.object_id != @population.object_id
      @population = population

      step = @sum.to_f/how_much
      ballot = step * @random.rand 

      width = 0.0
      winners = []
      @wheel.each_with_index do |slot,index|
        width += slot.width
        next if ballot > width
        winners.push slot.original   
        ballot += step
      end

      winners
    end

    def select_one population=self.population
      select( 1, population ).first
    end
  
  end

end # Selection

