
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
                 @cfg.factory('selection', @cfg.factory('rank') ) 
    @crossover = @cfg.factory('crossover')
    @mutation = @cfg.factory('mutation')   
    @report = @cfg.factory('report')

    @population = @store.load
    @population = [] if @population.nil?
    (@population_size-@population.size).times { @population.push @cfg.factory( 'individual', @mapper ) }
  end

  def teardown
    @store.save @population
    return @report   
  end

  def step
    
    @selection.population = @population
    new_population = []

    while new_population.size < @population_size
      if rand < @crossover_probability 
        parents = @selection.select 2
        breed, dummy = @crossover.crossover( parents.first, parents.last ) 
      else
        breed = @selection.select_one 
      end
      
      breed = @mutation.mutate breed if rand < @mutation_probability  
    
      new_population << @cfg.factory( 'individual', @mapper, breed ) 
    end

    @population = new_population

    return @report
  end

  def finished?
  end

end

