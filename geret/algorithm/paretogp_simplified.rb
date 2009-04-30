class ParetoGPSimplified
 
  attr_accessor :termination, :init, :population_size, :archive_size, :generations_per_cascade
  attr_accessor :archive_tourney_size, :population_tourney_size, :consolidation_tourney_size

  def setup config
    @cfg = config
    @report = @cfg.factory('report')
    @report << "--------- initialization:"
    
    @store = @cfg.factory('store')
    @grammar = @cfg.factory('grammar')
    @mapper = @cfg.factory('mapper', @grammar)

    @crossover = @cfg.factory('crossover')
    @mutation = @cfg.factory('mutation')   

    @archive = @store.load
    @archive = [] if @archive.nil?
    @report << "loaded #{@archive.size} individuals"   
    @report << "creating #{@archive_size - @archive.size} individuals"
    init_population( @archive, @archive_size )  

    @steps = 0
    return @report       
  end

  def step
    @report << "--------- step #{@steps += 1}" 
    @report.report @archive 
   
    @population = []
    init_population( @population, @population_size )   
  end

  def teardown
    @report << "--------- finished:"
    @store.save @population
    return @report   
  end

  def finished?
    max_steps = @termination['max_steps']
    on_individual = @termination['on_individual']
    if ( not max_steps.nil? and @steps >= max_steps ) or
       ( not on_individual.nil? and @population.detect { |individual| individual.send on_individual } )
 
      @report.report @population

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

