
require 'algorithm/algorithm_base'

class ParetoGPSimplified < AlgorithmBase
 
  attr_accessor :archive_size, :generations_per_cascade, :mutation_probability

  def setup config
    super

    @archive = @store.load
    @archive = [] if @archive.nil?
    @report << "loaded #{@archive.size} individuals"   
    @report << "creating #{@archive_size - @archive.size} individuals"
    init_population( @archive, @archive_size )  

    @population = []

    @archive_tourney = @cfg.factory( 'archive_tourney' )
    @population_tourney = @cfg.factory( 'population_tourney' )
    @consolidation_tourney = @cfg.factory( 'consolidation_tourney' )  # todo: needed?

    @steps = 0

    return @report       
  end

  def step
    @report << "--------- step #{@steps += 1}" 
    @report.report @archive 
   
    # init population
    @population = []
    init_population( @population, @population_size )   

    cross = mutate = 0
    @generations_per_cascade.times do

      # create a new population
      population_pipe = []
      archive_pipe = []
      new_population = []
      while new_population.size < @population_size

        population_pipe = @population_tourney.select_front @population while population_pipe.empty?
        archive_pipe = @archive_tourney.select_front @archive while archive_pipe.empty?

        chromozome1, chromozome2 = @crossover.crossover( population_pipe.shift.genotype, archive_pipe.shift.genotype )     
        cross += 1

        if rand < @mutation_probability 
          chromozome1 = @mutation.mutation chromozome1       
          mutate += 1
        end
        
        individual = @cfg.factory( 'individual', @mapper, chromozome1 ) 
        new_population << individual if individual.valid?
        individual = @cfg.factory( 'individual', @mapper, chromozome2 ) 
        new_population << individual if individual.valid?
       
      end
      @population = new_population
    
    end # of a single generation
  
    @report['numof_crossovers'] << cross   
    @report['numof_mutations'] << mutate

    # consolidate
    @archive.concat @population
    while @archive.size > @archive_size 
      dominated_ids = ParetoTourney.dominated( @archive ).map { |individual| individual.object_id }
      if dominated_ids.empty?
        @report << "cannot select dominated individuals, keeping a bigger archive.size=#{@archive.size}"
        break
      end
      @archive.delete_if { |individual| dominated_ids.include? individual.object_id }
    end

    return @report 
  end

end

