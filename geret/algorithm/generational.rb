
include Selection

class Generational

  attr_accessor :termination, :population_size, :elite_size, :crossover_probability, :mutation_probability

  def initialize
  end

  def setup config
    @cfg = config
    @store = @cfg.factory('store')
    @grammar = @cfg.factory('grammar')
    @mapper = @cfg.factory('mapper', @grammar)
    @selection = @cfg['rank'].nil? ? 
                 @cfg.factory('selection') : 
                 @cfg.factory('selection', @cfg.factory('selection_rank') ) 
    @rank = @cfg.factory('rank')             
    @crossover = @cfg.factory('crossover')
    @mutation = @cfg.factory('mutation')   
    @report = @cfg.factory('report')

    @population = @store.load
    @population = [] if @population.nil?
    (@population_size-@population.size).times { @population.push @cfg.factory( 'individual', @mapper ) }

    @next_stop = false
    @steps = 0

    return @report    
  end

  def teardown
    @store.save @population
    return @report   
  end

  def step
    ranked_population = @elite_rank.rank( @population ).map { |individual| individual.original }
    @report.report ranked_population

    new_population = ranked_population[0...@elite_size]  

    @selection.population = @population   
    while new_population.size < @population_size
      if rand < @crossover_probability 
        parents = @selection.select 2
        chromozome, dummy = @crossover.crossover( parents.first, parents.last ) 
      else
        chromozome = @selection.select_one 
      end
      
      chromozome = @mutation.mutate chromozome if rand < @mutation_probability  
      
      individual = @cfg.factory( 'individual', @mapper, chromozome ) 
      @next_stop = @next_stop || individual.send( @termination['on_individual'] ) unless @termination['on_individual'].nil? 

      new_population << individual
    end

    @population = new_population

    return @report
  end

  def finished?
    return true if !@termination['max_steps'].nil? and @steps >= @termination['max_steps']
    return @next_stop 
  end

end

