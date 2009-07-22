
module Selection

  # Select members of the population one by one, when reaching the last individual, 
  # start again from the first one (use wrapping).
  # 
  class RoundRobin
  
    # Set the population for the selection.
    def initialize population
      @index = 0
      @population = population
    end

    # Select one individual.
    def select_one
      res = @population[ @index ]
      @index = (@index+1).divmod( @population.size ).last
      res
    end

    # Select more individuals (how_much of them is the argument).
    def select how_much
      res = []
      how_much.times { res << select_one }
      res
    end

  end

end

