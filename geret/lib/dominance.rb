
class Dominance
  DominanceHelper = Struct.new( 'DominanceFields', :original, :dominated_by, :dominates )
  DominanceFields = Struct.new( 'DominanceFields', :original, :rank, :count )

  def initialize comparison = proc { |a,b| a<=>b }
    @comparison = comparison
  end

  def rank_count population
    dom = population.map { |orig| DominanceHelper.new( orig, {}, {} ) }

    dom.each_with_index do |individual1, index1|
      for index2 in ( (index1+1) ... dom.size )
        individual2 = dom[index2] 
        case @comparison.call( individual1.original, individual2.original )
        when 1
          individual1.dominates[individual2]=nil
          individual2.dominated_by[individual1]=nil         
        when -1
          individual2.dominates[individual1]=nil
          individual1.dominated_by[individual2]=nil         
        end
      end
    end

    if block_given?
      dom.each { |fields| yield( fields.original, fields.dominated_by.size, fields.dominates.size ) }
      return population
    else
      return dom.map { |fields| DominanceFields.new( fields.original, fields.dominated_by.size, fields.dominates.size )  }
    end
  end

end

