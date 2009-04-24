
module Selection

  class RoundRobin
  
    def initialize population
      @index = 0
      @population = population
    end

    def select_one
      res = @population[ @index ]
      @index = (@index+1).divmod( @population.size ).last
      res
    end

    def select how_much
      res = []
      how_much.times { res << select_one }
      res
    end

  end

end

