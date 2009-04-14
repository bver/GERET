
class ToyReport < ReportText 

  def report ranked_population
    self['genotypic_diversity'] << Utils.diversity( ranked_population ) { |individual| individual.genotype }
    self['phenotypic_diversity'] << Utils.diversity( ranked_population ) { |individual| individual.phenotype }
 
    min, max, avg, n = Utils.statistics( ranked_population.map { |individual| individual.error } )
    self['min_error'] << min
    self['max_error'] << max
    self['avg_error'] << avg

    min, max, avg, n = Utils.statistics( ranked_population.map { |individual| individual.used_length } )
    self['min_usedlen'] << min
    self['max_usedlen'] << max
    self['avg_usedlen'] << avg
  end

end

