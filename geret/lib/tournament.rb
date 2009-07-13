
require 'lib/ranking'
require 'lib/select_more'

module Selection

  # Tournament Selection method. This method selects the best individual from the randomly 
  # selected subset of the population. The subset size (tournament_size) and the pressure_modifier
  # parameters control the selection pressure.
  # 
  # See http://en.wikipedia.org/wiki/Tournament_selection 
  # 
  class Tournament
    include SelectMore

    # Set the instance of the Ranking object which will be used for ranking the population 
    # before the selection. 
    # The tournament_size and/or pressure_modifier can also be set (optional).
    def initialize ranker, tournament_size=2, pressure_modifier=1.0
      raise "Tournament: invalid Ranking object" unless ranker.kind_of? Ranking 
      @ranker = ranker
      @tournament_size = tournament_size 
      @random = Kernel
      @pressure_modifier = pressure_modifier
    end

    # The size of the random subset which is to be pre-selected for the tournament.
    attr_accessor :tournament_size

    # The instance of the Ranking object which will be used for ranking the subset (the rank.first is the winner).
    attr_accessor :ranker

    # The source of randomness, used for calling "random.rand( limit )", defaulting to 'Kernel' class.
    attr_accessor :random

    # The probability of the selection of the best individual from the subset. If the rank.first individual is not
    # selected, the second individual is chosen with the probability pressure_modifier*(1-pressure_modifier), etc.
    attr_accessor :pressure_modifier

    # The population to select from.
    attr_accessor :population

    # Select the individual from the population using the Tournament method.
    def select_one population=self.population
      raise "Tournament: empty population" if population.empty?
      raise "Tournament: tournament_size bigger than population.size" if @tournament_size > population.size 
     
      @population = population
      select_one_internal     
    end

    protected 

    def select_one_internal 
      selected = []
      while selected.size < @tournament_size
        selected.push @population[ @random.rand(@population.size) ]
      end

      ranked = @ranker.rank selected
      for rank in ( 0 ... @tournament_size )
        next if @random.rand > @pressure_modifier and rank < @tournament_size-1
        selection = ranked.find_all { |individual| individual.rank == rank }
        return selection[ @random.rand(selection.size) ].original
      end
    end

  end

end # Selection

