
require 'lib/roulette'
require 'lib/ranking'

module Selection

  # Rank Selection using given Ranking instance.
  # Selection operator which uses Roulette wheel selection applied on :proportion value 
  # of pre-ranked individuals.
  # 
  # See http://www.obitko.com/tutorials/genetic-algorithms/selection.php 
  # 
  class RankRoulette
    include SelectMore

    # Set the instance of the Ranking object which will be used for ranking the population 
    # before the selection.
    def initialize ranker
      raise "RankRoulette: invalid Ranking object" unless ranker.kind_of? Ranking     
      @ranker = ranker
      @roulette = Roulette.new :proportion
      @population = nil     
      @ranked = nil
    end

    # The population to select from.
    attr_accessor :population
    
    # Set the source of randomness for the roulette, using Roulette#random=
    def random= rnd
      @roulette.random = rnd
    end

    # Rank the population and then select one individual from it. The stochastic "slots" are
    # :proportion-al.
    def select_one population=self.population
      @ranked = @ranker.rank( population ) 
      @population = population

      select_one_internal
    end

    protected

    def select_one_internal
      @roulette.select_one( @ranked ).original
    end

  end

end


