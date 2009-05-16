
class ToyParetoReport < ReportText 

  def report population
    ers = population.map { |individual| individual.error } 
    min, max, avg, n = Utils.statistics( ers )
    diversity =  Utils.diversity( ers )
    self['diversity_error'] << diversity[0...10].inspect + " (#{diversity.size} unique)"

    lens = population.map { |individual| individual.used_length } 
    min, max, avg, n = Utils.statistics( lens )
    diversity =  Utils.diversity( lens )
    self['diversity_usedlen'] << diversity[0...10].inspect + " (#{diversity.size} unique)"

    combo = population.map { |individual| "#{individual.error},#{individual.used_length}" } 
    diversity =  Utils.diversity( combo )
    self['diversity_combo'] << diversity[0...10].inspect + " (#{diversity.size} unique)"

    uniq = {}
    count = {}
    count.default = 0
    population.each do |individual| 
      uniq[individual.phenotype] = individual 
      count[individual.phenotype] += 1
    end
    sorted = uniq.values.sort { |a,b| a.error <=> b.error }
    text = "\n"
    sorted.each { |i| text += "#{count[i.phenotype]}*[#{i.error}, #{i.used_length}] #{i.phenotype}\n" }
    self['elite'] << text
  end

end

