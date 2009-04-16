
class ToyReport < ReportText 

  def report ranked_population
    diversity = Utils.diversity( ranked_population ) { |individual| individual.genotype }
    self['diversity_genotypic'] << diversity[0...10].inspect   
    
    diversity =  Utils.diversity( ranked_population ) { |individual| individual.phenotype }
    self['diversity_phenotypic'] << diversity[0...10].inspect

    errors = ranked_population.map { |individual| individual.error }   
    min, max, avg, n = Utils.statistics( errors.find_all { |e| e.infinite?.nil? } )
    self['error_min'] << min
    self['error_max'] << max
    self['error_avg'] << avg
    self['error_finites'] << n 

    min, max, avg, n = Utils.statistics( ranked_population.map { |individual| individual.used_length } )
    self['usedlen_min'] << min
    self['usedlen_max'] << max
    self['usedlen_avg'] << avg

    min, max, avg, n = Utils.statistics( ranked_population.map { |individual| individual.genotype.size } )
    self['gensize_min'] << min
    self['gensize_max'] << max
    self['gensize_avg'] << avg

    self['winner'] << ranked_population.first.phenotype
  end

end

