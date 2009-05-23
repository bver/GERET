
class Dominance
  DominanceHelper = Struct.new( 'DominanceHelper', :original, :dominated_by, :dominates )
  DominanceFields = Struct.new( 'DominanceFields', :original, :rank, :count )
  DominanceDepth = Struct.new( 'DominanceDepth', :original, :depth, :counter, :dominates )

  def initialize &comparison
    comparison = proc { |a,b| a<=>b } if comparison.nil?
    @comparison = comparison
    @at_least = nil
  end

  attr_accessor :at_least

  def rank_count population
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

    if block_given?
      dom.each { |fields| yield( fields.original, fields.dominated_by.size, fields.dominates.size ) }
      return population
    else
      return dom.map { |fields| DominanceFields.new( fields.original, fields.dominated_by.size, fields.dominates.size )  }
    end
  end

  # see Deb's NGSA2 O(MN^2)
  def depth population
    dom = depth_core population
    return dom unless block_given?
    dom.each { |fields| yield( fields.original, fields.depth ) }
  end

  protected

  def depth_core population
    classified = 0
    nondominated = []
    dom = population.map { |orig| DominanceDepth.new( orig, nil, 0, {} ) }
    dom.each do |p|
      dom.each_with_index do |q,qindex|
        next if p.original.object_id == q.original.object_id
        case @comparison.call( p.original, q.original )
        when 1
          p.dominates[qindex]=nil
        when -1
          p.counter += 1 
        end
      end
      if p.counter == 0
        p.depth = 0       
        classified += 1
        nondominated.push p
      end
    end

    return dom if @at_least != nil and classified >= @at_least

    front = 0
    until nondominated.empty?
      nextfront = []
      nondominated.each do |p|
        p.dominates.keys.each do |qindex|
          q = dom[qindex]
          q.counter -= 1
          next unless q.counter == 0
          q.depth = front + 1
          nextfront.push q
        end
      end
      front += 1
      nondominated = nextfront
      classified += nondominated.size
      return dom if @at_least != nil and classified >= @at_least     
    end
   
    raise "Dominance: possibly cyclic dominance found" unless nil == dom.detect {|i| i.depth == nil }
    dom
  end

end

