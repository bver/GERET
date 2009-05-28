
require 'algorithm/algorithm_base'

class ParetoGPSimplified < AlgorithmBase
 
  attr_accessor :archive_size, :generations_per_cascade, :mutation_probability

  def setup config
    super

    @archive = @store.load
    @archive = [] if @archive.nil?
    @report << "loaded #{@archive.size} archive individuals"   
    @report << "creating #{@archive_size - @archive.size} archive individuals"
    init_population( @archive, @archive_size )  

    @population = []
    @elite = []

    @archive_tourney = @cfg.factory( 'archive_tourney' )
    @population_tourney = @cfg.factory( 'population_tourney' )
    @consolidation = @cfg['consolidation_rank'].nil? ? 
                     @cfg.factory('consolidation') : 
                     @cfg.factory('consolidation', @cfg.factory('consolidation_rank') ) 

    @steps = 0
    @generation = 0
    return @report       
  end

  def step
    @report << "--------- step #{@steps += 1}, generation #{@generation}" 

     # init population   
    if @generation == 0
      @report << "initializing population"  
      @population = []
      @elite = []
      init_population( @population, @population_size )   
    end

    # create a new population from the current one
    population_pipe = []
    archive_pipe = []
    new_population = @elite
    while new_population.size < @population_size

      population_pipe = @population_tourney.select_front @population while population_pipe.empty?
      #archive_pipe = @archive_tourney.select_front @archive while archive_pipe.empty?
      archive_pipe = Utils.permutate @archive while archive_pipe.empty?

      chromozome1, chromozome2 = @crossover.crossover( population_pipe.shift.genotype, archive_pipe.shift.genotype )     

      chromozome1 = @mutation.mutation chromozome1 if rand < @mutation_probability 
        
      individual = @cfg.factory( 'individual', @mapper, chromozome1 ) 
      new_population << individual if individual.valid?
      individual = @cfg.factory( 'individual', @mapper, chromozome2 ) 
      new_population << individual if individual.valid?
       
    end
    @population = new_population
  
#    @report << 'new population'
#    @report.report new_population

    @elite = ParetoTourney.front( @population )
    uniq = {}
    @elite.each do |individual|
      individual.shorten_chromozome = true
      uniq[ individual.genotype ] = individual
    end
    @elite = uniq.values
    @report['elite_size'] << @elite.size

    fits = @population.map { |individual| individual.fitness } 
    min, max, avg, n = Utils.statistics( fits )
    @report['pop_fitness_max'] << max
    @report['pop_fitness_avg'] << avg


    # consolidation
    if @generation == @generations_per_cascade 

      @archive.concat @elite # @population
      @archive = ParetoTourney.front( @archive )
#      if @archive.size > @archive_size
        uniq = {}
        @archive.each do |individual| 
          individual.shorten_chromozome = true         
          uniq[ individual.genotype ] = individual
        end
        @archive = uniq.values
#      end



#      to_be_removed =  @archive.size - @archive_size
#      if to_be_removed > 0
#        ids = @consolidation.select( to_be_removed, @archive ).map { |individual| individual.object_id }
#        @archive.delete_if { |individual| ids.include? individual.object_id }
#        @report['removed_from_archive'] << to_be_removed
#      end

#      if @archive.size > @archive_size
#        uniq = {}
#        @archive.each { |individual| uniq[ individual.phenotype ] = individual }
#        @archive = uniq.values
#        puts "!!!!  #{@archive.size}"
#      end

#      @archive.each { |individual| uniq[ individual.genotype ]=nil }
#      @archive = uniq.keys.map { |chromozome| @cfg.factory( 'individual', @mapper, chromozome ) }

#      while @archive.size > @archive_size 
#        dominated_ids = ParetoTourney.dominated( @archive ).map { |individual| individual.object_id }
#        @report['dominated_removed'] << dominated_ids.size        
#        if dominated_ids.empty?
#          @report << "cannot select dominated individuals, keeping a bigger archive.size=#{@archive.size}"
#          break
#        end
#        @archive.delete_if { |individual| dominated_ids.include? individual.object_id }
#      end

      @report << "archive consolidation"     
      @report.report @archive      
      @generation = 0
    else
      @generation += 1
    end # consolidation

    @report.next     
    return @report 
  end

end

