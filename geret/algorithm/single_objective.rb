
include Selection

class SingleObjective

  attr_accessor :termination, :init, :inject, :population_size, :probabilities

  def setup config
    @cfg = config
    @report = @cfg.factory('report')
    @report << "--------- initialization:"
    
    @store = @cfg.factory('store')
    @grammar = @cfg.factory('grammar')
    @mapper = @cfg.factory('mapper', @grammar)
    @selection = @cfg['selection_rank'].nil? ? 
                 @cfg.factory('selection') : 
                 @cfg.factory('selection', @cfg.factory('selection_rank') ) 
    @crossover = @cfg.factory('crossover')
    @mutation = @cfg.factory('mutation')   

    @population = @store.load
    @population = [] if @population.nil?
    @report << "loaded #{@population.size} individuals"   
    @report << "creating #{@population_size - @population.size} individuals"     
    while @population.size < @population_size
      individual = @cfg.factory( 'individual', @mapper, init_chromozome(@init) )
      @population << individual if individual.valid? 
    end

    @steps = 0

    return @report    
  end

  def teardown
    @report << "--------- finished:"
    @store.save @population
    return @report   
  end

  def finished?
    if ( ! @termination['max_steps'].nil? and @steps >= @termination['max_steps'] ) or
       ( ! @termination['on_individual'].nil? and @population.detect { |individual| individual.send @termination['on_individual'] } )
 
      @report.report @population

      return true
    end
    return false
  end

  protected

  def breed_individual
    if rand < @probabilities['crossover'] 
      parents = @selection.select 2 
      chromozome, dummy = @crossover.crossover( parents.first.genotype, parents.last.genotype ) 
      @cross += 1
    else
      if rand < @probabilities['injection']
        chromozome = init_chromozome @inject
        @injections += 1
      else
        chromozome = @selection.select_one.genotype 
        @copies +=1
      end
    end
   
    if rand < @probabilities['mutation']
      chromozome = @mutation.mutation chromozome   
      @mutate += 1
    end
      
    return @cfg.factory( 'individual', @mapper, chromozome ) 
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

