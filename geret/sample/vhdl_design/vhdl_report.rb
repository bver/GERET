
class VhdlReport < ReportText 

  def report population
    diversity = Util.diversity( population ) { |individual| individual.genotype }
    self['diversity_genotypic'] << diversity[0...10].inspect + " (#{diversity.size} unique)"  
    
#    diversity =  Util.diversity( population ) { |individual| individual.phenotype }
#    self['diversity_phenotypic'] << diversity[0...10].inspect + " (#{diversity.size} unique)"

    fits = population.map { |individual| individual.fitness } 
    min, max, avg, n = Util.statistics( fits )
    self['fitness_max'] << max
    self['fitness_avg'] << avg
    self['fitness_size'] << n 
    diversity =  Util.diversity( fits )
    self['diversity_fitness'] << diversity[0...10].inspect + " (#{diversity.size} unique)"

    min, max, avg, n = Util.statistics( population.map { |individual| individual.used_length } )
    self['usedlen_min'] << min
    self['usedlen_max'] << max
    self['usedlen_avg'] << avg

    min, max, avg, n = Util.statistics( population.map { |individual| individual.genotype.size } )
    self['gensize_min'] << min
    self['gensize_max'] << max
    self['gensize_avg'] << avg

    best = population.max { |a,b| a.fitness <=> b.fitness }
    self['best_phenotype'] << "\n#{best.phenotype}"

    uniq = {}
    count = {}
    count.default = 0
    population.each do |individual| 
      uniq[individual.phenotype] = individual 
      count[individual.phenotype] += 1
    end
    sorted = uniq.values.sort { |a,b| b.fitness <=> a.fitness }
    text = "\n"
    sorted[0...10].each { |i| text += "#{count[i.phenotype]}*[#{i.fitness}, #{i.used_length}]\n" }
    text += "..." if sorted.size > 10
    self['phenotypes'] << text
    
  end

end

