
class FclReport < ReportText 

  def report population
    diversity = Util.diversity( population ) { |individual| individual.genotype }
    self['diversity_genotypic'] << diversity[0...10].inspect   
    
    errors = population.map { |individual| individual.error }   
    min, max, avg, n = Util.statistics( errors.find_all { |e| e.infinite?.nil? } )
    self['error_min'] << min
    self['error_max'] << max
    self['error_avg'] << avg
    self['error_finites'] << n 

    min, max, avg, n = Util.statistics( population.map { |individual| individual.used_length } )
    self['usedlen_min'] << min
    self['usedlen_max'] << max
    self['usedlen_avg'] << avg

    min, max, avg, n = Util.statistics( population.map { |individual| individual.genotype.size } )
    self['gensize_min'] << min
    self['gensize_max'] << max
    self['gensize_avg'] << avg

    best = population.min do |a,b| 
      c = a.error <=> b.error
      (c == 0)? a.used_length <=> b.used_length  : c 
    end
    self['best_phenotype'] << best.phenotype

    uniq = {}
    count = {}
    count.default = 0
    population.each do |individual| 
      uniq[individual.phenotype] = individual 
      count[individual.phenotype] += 1
    end
    sorted = uniq.values.sort { |a,b| a.error <=> b.error }
    text = "\n"
    sorted[0...10].each { |i| text += "#{count[i.phenotype]}*[#{i.error}, #{i.used_length}]\n" }
    text += "..." if sorted.size > 10
    self['phenotypes'] << text
   
  end

end

