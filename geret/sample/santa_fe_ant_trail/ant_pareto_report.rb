
class AntParetoReport < ReportText 

  def report population
    diversity = Utils.diversity( population ) { |individual| individual.genotype }
    self['diversity_genotypic'] << diversity[0...10].inspect + " (#{diversity.size} unique)"  
    
    diversity =  Utils.diversity( population ) { |individual| individual.phenotype }
    self['diversity_phenotypic'] << diversity[0...10].inspect + " (#{diversity.size} unique)"

    fits = population.map { |individual| individual.fitness } 
    min, max, avg, n = Utils.statistics( fits )
    self['fitness_max'] << max
    self['fitness_avg'] << avg
    self['archive_size'] << n
    diversity =  Utils.diversity( fits )
    self['diversity_fitness'] << diversity[0...10].inspect + " (#{diversity.size} unique)"

    lens = population.map { |individual| individual.used_length } 
    min, max, avg, n = Utils.statistics( lens )
    self['usedlen_min'] << min
    self['usedlen_max'] << max
    self['usedlen_avg'] << avg
    diversity =  Utils.diversity( lens )
    self['diversity_usedlen'] << diversity[0...10].inspect + " (#{diversity.size} unique)"


    min, max, avg, n = Utils.statistics( population.map { |individual| individual.genotype.size } )
    self['gensize_min'] << min
    self['gensize_max'] << max
    self['gensize_avg'] << avg

    best = population.max  { |a,b| a.fitness <=> b.fitness }
    self['best_fit_phenotype'] << "\n#{best.phenotype}"
  end

end

