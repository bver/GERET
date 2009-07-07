
require 'lib/roulette'

module Selection

  # Stochastic Universal Sampling selection method. The probability of the individual selection is
  # proportional to some (usually fitness) non-negative value (as in Roulette selection).
  # However, more individuals can be selected at once by the single run of a wheel, which brings 
  # a better spread of the results.
  # 
  # See http://en.wikipedia.org/wiki/Stochastic_universal_sampling 
  # 
  class Sampling < Roulette
  
    # Set the proportional_by or the block for obtaining invividual's proportion.
    # See Roulette#proportional_by
    def initialize( proportional_by=nil, &block )
      super
    end

    # Select individuals from the population. 
    # It can be specified how_much individuals will be selected.
    def select( how_much, population=self.population )
      raise "Sampling: cannot select from an empty population" if population.empty?
      raise "Sampling: cannot select more than population.size" if how_much > population.size
      return [] if how_much == 0

      @sum,@wheel = wheel_core population 
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

    # Select one individual from the population (same as Roulette#select_one, but a bit less effective).
    def select_one population=self.population
      select( 1, population ).first
    end
  
  end

end # Selection

