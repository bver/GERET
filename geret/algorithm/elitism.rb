
module Elitism

  attr_accessor :elite_size

  protected 
  
  def init_elitism population_size
    raise "Elitism: elite_size >= population_size" if @elite_size >= population_size
    @elite_rank = @cfg.factory('elite_rank') unless @elite_size == 0    
  end

  def elite population
    return [] if @elite_size == 0
    ranked_population = ( @elite_rank.rank population ).map { |ranked| ranked.original }
    new_population = ranked_population[0...@elite_size]  
  end
  
end

