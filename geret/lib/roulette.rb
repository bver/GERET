
require 'lib/select_more'

module Selection

  # Roulette Selection method. This is the classic stochastic selection method with the probability 
  # of the individual selection proportional to some (usually fitness) non-negative value.
  # 
  # See http://www.obitko.com/tutorials/genetic-algorithms/selection.php 
  # 
  class Roulette
    include SelectMore

    Slot = Struct.new( 'Slot', :original, :width )

    # Set the proportional_by or the block for obtaining invividual's proportion.
    def initialize proportional_by=nil, &block
      @prop = if proportional_by.nil?
                block
              else
                proc { |individual| individual.send(proportional_by) }
              end
      @proportional_by = proportional_by     
      @random = Kernel
      @population = nil 
      @wheel = nil
    end

    # The source of randomness, used for calling "random.rand( limit )", defaulting to 'Kernel' class.
    attr_accessor :random
   
    # The population to select from.
    attr_accessor :population

    # The symbol for obtaining the proportion of an individual.
    # The Roulette expect the proportion value on the call 'individual.send(proportional_by)'
    attr_reader :proportional_by

    # Select one individual from the population. 
    def select_one population=self.population 
      @sum,@wheel = wheel_core population 
      @population = population
      select_one_internal
    end

    # See proportional_by attribute.
    def proportional_by= proportional_by
      @prop = proc { |individual| individual.send(proportional_by) }
      @proportional_by = proportional_by     
    end

    protected

    def select_one_internal
      ballot = @sum * @random.rand   

      sum = 0.0
      @wheel.each do |slot|
        sum += slot.width
        return slot.original if sum > ballot
      end
     
      return @wheel.last.original
    end
   
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

