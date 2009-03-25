
class Dominance
  DominanceHelper = Struct.new( 'DominanceHelper', :original, :dominated_by, :dominates )
  DominanceFields = Struct.new( 'DominanceFields', :original, :rank, :count )
  DominanceDepth = Struct.new( 'DominanceDepth', :original, :depth )

  def initialize &comparison
    comparison = proc { |a,b| a<=>b } if comparison.nil?
    @comparison = comparison
  end

  def rank_count population
    dom = coreMatrix population

    if block_given?
      dom.each { |fields| yield( fields.original, fields.dominated_by.size, fields.dominates.size ) }
      return population
    else
      return dom.map { |fields| DominanceFields.new( fields.original, fields.dominated_by.size, fields.dominates.size )  }
    end
  end

  def depth population
    dom = coreMatrix population
    result = dom.map { |f| DominanceDepth.new( f.original ) }
    depth = 0
    until dom.empty?
      nondominated = dom.find_all { |f| f.dominated_by.empty? }
      nondominated.each do |nd|
        dom.delete nd
        dom.each { |f| f.dominated_by.delete nd.object_id }
        ndres = result.find { |f| nd.original == f.original }
        ndres.depth = depth
      end
      depth += 1
    end

    return result unless block_given?
    result.each { |fields| yield( fields.original, fields.depth ) }
  end

  protected

  def coreMatrix population
    dom = population.map { |orig| DominanceHelper.new( orig, {}, {} ) }

    dom.each_with_index do |individual1, index1|
      for index2 in ( (index1+1) ... dom.size )
        individual2 = dom[index2] 
        case @comparison.call( individual1.original, individual2.original )
        when 1
          individual1.dominates[individual2.object_id]=nil
          individual2.dominated_by[individual1.object_id]=nil         
        when -1
          individual2.dominates[individual1.object_id]=nil
          individual1.dominated_by[individual2.object_id]=nil         
        end
      end
    end
 
    dom
  end

end

