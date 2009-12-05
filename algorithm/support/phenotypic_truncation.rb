
module PhenotypicTruncation

  attr_accessor :shorten_individual

  def phenotypic_truncation( population, max_size )
    # prepare phenotypic hash
    uniq = {}
    population.each do |individual|
      individual.shorten_chromozome = @shorten_individual
      slot = uniq.fetch( individual.phenotype, [] ) 
      slot.push individual
      uniq[individual.phenotype] = slot
    end

    # trim archive size, decimate duplicate phenotypes first
    current_size = uniq.values.flatten.size
    while current_size > max_size 
      candidate = uniq.values.max {|a,b| a.size <=> b.size }
      break if candidate.size == 1
      candidate.pop
      current_size -= 1
    end
    uniq.values.flatten
  end

end

