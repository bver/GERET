
require 'lib/sampling'
require 'lib/ranking'

module Selection

  # Stochastic Universal Sampling Selection using given Ranking instance.
  # Selection operator which uses SUS selection applied on :proportion value 
  # of pre-ranked individuals.
  #
  # http://en.wikipedia.org/wiki/Stochastic_universal_sampling 
  class RankSampling

    # Set the instance of the Ranking object which will be used for ranking the population 
    # before the selection.
    def initialize ranker
      raise "RankSampling: invalid Ranking object" unless ranker.kind_of? Ranking     
      @ranker = ranker
      @sampling = Sampling.new :proportion
      @population = nil     
    end
  
    # The population to select from.   
    attr_accessor :population

    # Set the source of randomness for the roulette, using Sampling#random=   
    def random= rnd
      @sampling.random = rnd
    end

    # Rank the population and then select individuals from it. The stochastic "slots" are
    # :proportion-al. It can be specified how_much individuals will be selected.
    def select( how_much, population=self.population )
      ranked = @ranker.rank( population ) 
      @population = population
     
      @sampling.select( how_much, ranked ).map { |individual| individual.original }
    end

    # Rank the population and then select one individual from it. The stochastic "slots" are
    # :proportion-al.
    def select_one population=self.population
      select( 1, population ).first
    end
    
  end

end


