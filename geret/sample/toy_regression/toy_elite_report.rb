
class ToyParetoReport < ReportText 

  def report population
    diversity =  Utils.diversity( population ) { |individual| individual.phenotype }
    self['diversity_phenotypic'] << diversity[0...10].inspect + " (#{diversity.size} unique)"

    ers = population.map { |individual| individual.error } 
    min, max, avg, n = Utils.statistics( ers )
    self['error_min'] << min
    self['error_max'] << max
    self['error_avg'] << avg
    diversity =  Utils.diversity( ers )
    self['diversity_error'] << diversity[0...10].inspect + " (#{diversity.size} unique)"

    lens = population.map { |individual| individual.used_length } 
    min, max, avg, n = Utils.statistics( lens )
    self['usedlen_min'] << min
    self['usedlen_max'] << max
    self['usedlen_avg'] << avg
    diversity =  Utils.diversity( lens )
    self['diversity_usedlen'] << diversity[0...10].inspect + " (#{diversity.size} unique)"

    combo = population.map { |individual| "#{individual.error},#{individual.used_length}" } 
    diversity =  Utils.diversity( combo )
    self['diversity_combo'] << diversity[0...10].inspect + " (#{diversity.size} unique)"

    min, max, avg, n = Utils.statistics( population.map { |individual| individual.genotype.size } )
    self['gensize_min'] << min
    self['gensize_max'] << max
    self['gensize_avg'] << avg

    best = population.min { |a,b| a.error <=> b.error }
    self['best_phenotype'] << best.phenotype
  end

end

