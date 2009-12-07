
include Selection
include Operator
include Moea
include Util

class AlgorithmBase

  attr_accessor :termination, :init, :population_size, :probabilities

  def setup config
    @cfg = config
    @report = @cfg.factory('report')
    @report << "--------- initialization:"
    
    @store = @cfg.factory('store')
    @grammar = @cfg.factory('grammar')
    @mapper = @cfg.factory('mapper', @grammar)
    @crossover = @cfg.factory('crossover')
    @mutation = @cfg.factory('mutation', @grammar)   

    unless @cfg['selection'].nil?
      @selection = @cfg['selection_rank'].nil? ? 
                   @cfg.factory('selection') : 
                   @cfg.factory('selection', @cfg.factory('selection_rank') ) 
    end

   
    @evaluator = @cfg.factory('evaluator') unless @cfg['evaluator'].nil? 

    @steps = 0

    return @report    
  end

  def teardown
    @report << "--------- finished:"
    @store.save @population
    return @report   
  end
 
  def finished?
    max_steps = @termination['max_steps'].to_i
    on_individual = @termination['on_individual']
    if ( not max_steps.nil? and @steps >= max_steps ) or
       ( not on_individual.nil? and @population.detect { |individual| individual.send on_individual } )
 
      @report.report @population

      return true
    end
    return false
  end

  protected

  def load_or_init( store, population_size )
    population = store.load
    population = [] if population.nil?
    @report << "loaded #{population.size} individuals"   
    @report << "creating #{population_size - population.size} individuals"
    return init_population( population, population_size )
  end

  def init_population( population, population_size ) 
    if @init['method'] == 'ramped'

      @init['method'] = 'full'
      depth = @init['sensible_depth']
      while population.size < population_size
        individual = @cfg.factory( 'individual', @mapper, init_chromozome(@init) )
        next unless individual.valid? 
        population << individual       
        @init['method'] = ( @init['method'] == 'full' ) ? 'grow' : 'full'     
        if population.size.divmod(2).last == 0
          @init['sensible_depth'] = ( @init['sensible_depth'] == depth ) ? 2 : @init['sensible_depth']+1
        end
      end

    else

      while population.size < population_size
        individual = @cfg.factory( 'individual', @mapper, init_chromozome(@init) )
        population << individual if individual.valid? 
      end

    end

    @evaluator.run population if defined? @evaluator
    population
  end

  def init_chromozome hash
    case hash['method']
    when 'random'
      RandomInit.new( hash['random_magnitude'] ).init( hash['random_length'] )
    when 'grow'
      @mapper.generate_grow hash['sensible_depth']
    when 'full'
      @mapper.generate_full hash['sensible_depth']
    else
      raise "Generational: init method #{hash['method']} not implemented"
    end
  end

end
