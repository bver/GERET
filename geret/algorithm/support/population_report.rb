
class PopulationReport < ReportText 

  def report population
    post_initialize unless defined? @objective

    diversity = Util.diversity( population ) { |individual| individual.genotype }
    self['diversity_genotypic'] << "#{diversity[0...10].inspect}#{ diversity.size>10 ? '...' : ''  } #{diversity.size} unique"   
    
    diversity =  Util.diversity( population ) { |individual| individual.phenotype }
    self['diversity_phenotypic'] << "#{diversity[0...10].inspect}#{ diversity.size>10 ? '...' : ''  } #{diversity.size} unique"

    values = population.map { |individual| individual.send(@objective) }   
    min, max, avg, n = Util.statistics values  
    self[@objective.to_s] << "min: #{min} max: #{max} avg: #{avg} n: #{n}"

    min, max, avg, n = Util.statistics( population.map { |individual| individual.used_length } )
    self['used_length'] << "min: #{min} max: #{max} avg: #{avg} n: #{n}"

    min, max, avg, n = Util.statistics( population.map { |individual| individual.complexity } )
    self['complexity'] << "min: #{min} max: #{max} avg: #{avg} n: #{n}"
   
    min, max, avg, n = Util.statistics( population.map { |individual| individual.genotype.size } )
    self['genotype.size'] << "min: #{min} max: #{max} avg: #{avg} n: #{n}"

    best = population.min do |a,b| 
      c = @sort_proc.call(a,b) 
      (c == 0)? a.complexity <=> b.complexity  : c 
    end
    self['best_phenotype'] << "\n#{best.phenotype}"

    uniq = {}
    count = {}
    count.default = 0
    population.each do |individual| 
      uniq[individual.phenotype] = individual 
      count[individual.phenotype] += 1
    end
    
    sorted = uniq.values.sort { |a,b| @sort_proc.call(a,b) }
    text = "\n"
    sorted[0...10].each { |i| text += format_individual( count[i.phenotype], i ) }
    text += "...\n" if sorted.size > 10
    if sorted.size > 15
      sorted[-5,5].each { |i| text += format_individual( count[i.phenotype], i ) } 
    end
    self['z_histogram'] << text
   
  end

  protected

  def post_initialize
    schema = PipedIndividual.pipe_schema
    raise "PopulationReport: exactly one pipe output handled" unless schema.size == 1

    @objective = schema.first

    @sort_proc = PipedIndividual.symbol_maximized?(@objective) ?
      proc { |a,b| b.send(@objective) <=> a.send(@objective) } :
      proc { |a,b| a.send(@objective) <=> b.send(@objective) }
  end
 
  def format_individual( count, i )
    "#{count}*[#{@objective}: #{i.send(@objective)}, complexity: #{i.complexity}]\n"
  end

end

