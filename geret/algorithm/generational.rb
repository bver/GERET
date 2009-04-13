
class Generational

  attr_accessor :termination, :population_size, :elite_size, :crossover_probability, :mutation_probability
  def initialize
  end

  def setup config
    @cfg = config
    @store = @cfg.factory('store')
    @grammar = @cfg.factory('grammar')
    @mapper = @cfg.factory('mapper', @grammar)
    @selection = @cfg.factory('selection')
    @crossover = @cfg.factory('crossover')
    @mutation = @cfg.factory('mutation')   
    @report = @cfg.factory('report')

    @population = @store.load
    if @population.nil?
      @population = []
      @population_size.times { @population.push  @cfg.factory( 'individual', @mapper ) }
    end
  end

  def teardown
    @store.save @population
    return @report   
  end

  def step
    ranker = Rank.new
    ranked = ranker.rank @population
    new_population = ranked.slice(0...@elite_size).map {|r| r.original }
    mating_pool = @selection.select( @population, @population_size/2 ) 
#todo
    
    @population = new_population
    return @report
  end

  def finished?
  end

end

