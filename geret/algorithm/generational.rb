
include Selection

class Generational

  attr_accessor :termination, :init, :inject, :population_size, :elite_size, :probabilities

  def initialize
  end

  def setup config
    raise "Generational: elite_size >= population_size" if @elite_size >= @population_size

    @cfg = config
    @report = @cfg.factory('report')
    @report << "--------- initialization:"
    
    @store = @cfg.factory('store')
    @grammar = @cfg.factory('grammar')
    @mapper = @cfg.factory('mapper', @grammar)
    @selection = @cfg['selection_rank'].nil? ? 
                 @cfg.factory('selection') : 
                 @cfg.factory('selection', @cfg.factory('selection_rank') ) 
    @elite_rank = @cfg.factory('elite_rank')     
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

  def step
    @report << "--------- step #{@steps += 1}" 

    ranked_population = ( @elite_rank.rank @population ).map { |ranked| ranked.original }
    @report.report ranked_population
       
    new_population = ranked_population[0...@elite_size]  
    @selection.population = @population  

    cross, inject, mutate, copies = 0, 0, 0, 0
    while new_population.size < @population_size
      if rand < @probabilities['crossover'] 
        parents = @selection.select 2 
        chromozome, dummy = @crossover.crossover( parents.first.genotype, parents.last.genotype ) 
        cross += 1
      else
        if rand < @probabilities['injection']
          chromozome = init_chromozome @inject
          inject += 1
        else
          chromozome = @selection.select_one.genotype 
          copies +=1
        end
      end
   
      if rand < @probabilities['mutation']
        chromozome = @mutation.mutation chromozome   
        mutate += 1
      end
      
      individual = @cfg.factory( 'individual', @mapper, chromozome ) 
      new_population << individual if individual.valid?
    end

    @report['numof_crossovers'] << cross   
    @report['numof_injections'] << inject
    @report['numof_copies'] << copies
    @report['numof_mutations'] << mutate
    @population = new_population

    @report.next   
    return @report
  end

  def finished?
    if ( ! @termination['max_steps'].nil? and @steps >= @termination['max_steps'] ) or
       ( ! @termination['on_individual'].nil? and @population.detect { |individual| individual.send @termination['on_individual'] } )
 
      ranked_population = ( @elite_rank.rank @population ).map { |ranked| ranked.original }
      @report.report ranked_population

      return true
    end
    return false
  end

  protected

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

