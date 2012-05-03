
module PopulationStatistics 

  attr_accessor :report_diversity, :report_statistics, :report_histogram, :report_pareto_front 

  def report population
    post_initialize unless defined? @objective

    if defined? @report_diversity and @report_diversity == true
      diversity = Util.diversity( population ) { |individual| individual.genotype }
      self['diversity_genotypic'] << "#{diversity[0...10].inspect}#{ diversity.size>10 ? '...' : ''  } #{diversity.size} unique"   
    
      diversity =  Util.diversity( population ) { |individual| individual.phenotype }
      self['diversity_phenotypic'] << "#{diversity[0...10].inspect}#{ diversity.size>10 ? '...' : ''  } #{diversity.size} unique"
    end

    if defined? @report_statistics and @report_statistics == true   
      values = population.map { |individual| individual.send(@objective) }   
      min, max, avg, n = Util.statistics values  
      self[@objective.to_s] << "min: #{min} max: #{max} avg: #{avg} n: #{n}"

      min, max, avg, n = Util.statistics( population.map { |individual| individual.used_length } )
      self['used_length'] << "min: #{min} max: #{max} avg: #{avg} n: #{n}"

      min, max, avg, n = Util.statistics( population.map { |individual| individual.complexity } )
      self['complexity'] << "min: #{min} max: #{max} avg: #{avg} n: #{n}"
   
      min, max, avg, n = Util.statistics( population.map { |individual| individual.genotype.size } )
      self['genotype.size'] << "min: #{min} max: #{max} avg: #{avg} n: #{n}"
    end

    best = population.min do |a,b| 
      c = @sort_proc.call(a,b) 
      (c == 0)? a.complexity <=> b.complexity  : c 
    end
    self['best_phenotype'] << "\n#{best.phenotype}"
    self['best_phenotype_complexity'] << best.complexity
    self['best_phenotype_layer'] << best.layer
    self['best_phenotype_age'] << best.age  

    if defined? @report_histogram and @report_histogram == true         
      uniq = {}
      count = {}
      count.default = 0
      population.each do |individual| 
        uniq[individual.phenotype] = individual 
        count[individual.phenotype] += 1
      end
    
      sorted = uniq.values.sort { |a,b| @sort_proc.call(a,b) }
      text = "\n"
      sorted[0...10].each { |i| text += format_individual( count[i.phenotype], i ) + "\n" }
      text += "...\n" if sorted.size > 10
      if sorted.size > 15
        sorted[-5,5].each { |i| text += format_individual( count[i.phenotype], i ) + "\n" } 
      end
      self['z_histogram'] << text
    end

    if defined? @report_pareto_front and @report_pareto_front == true
      uniq = {}
      Pareto.nondominated( population ).each do |individual| 
        uniq[individual.phenotype] = individual 
      end

      text = "\n"
      sorted = uniq.values.sort { |a,b| @sort_proc.call(a,b) }
      sorted.each { |i| text += format_individual( '', i ) + ': ' + i.phenotype + "\n" }
      
      self['pareto_front'] << text
    end

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
    age = ", age: #{i.age}" if i.respond_to? :age
    "#{count}*[#{@objective}: #{i.send(@objective)}, complexity: #{i.complexity}#{age}]"
  end

end


class PopulationReport < ReportText
  include PopulationStatistics
end

class PopulationReportStream < ReportStream
  include PopulationStatistics
end

