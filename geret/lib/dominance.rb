
require 'set'

class Dominance
  DominanceFields = Struct.new( 'DominanceHelper', :original, :rank, :dominates, :spea, :count )
  DominanceDepth = Struct.new( 'DominanceDepth', :original, :depth, :counter, :dominates )

  def initialize
    @at_least = nil
  end

  attr_accessor :at_least

  def rank_count population
    dom = population.map { |orig| DominanceFields.new( orig, 0, Set.new, 0 ) }

    dom.each do |individual1|
      dom.each_with_index do |individual2,index2|
        if individual1.original.dominates? individual2.original
          individual1.dominates.add(index2)
          individual2.rank += 1
        end
      end
    end

    dom.each do |individual|
      individual.dominates.each { |index| dom[index].spea += individual.dominates.size }
      individual.count = individual.dominates.size
    end

    if block_given?
      dom.each { |fields| yield( fields.original, fields.rank, fields.count, fields.spea ) }
      return population
    end
    
    dom
  end

  # see Deb's NGSA2 O(MN^2)
  def depth population
    dom, front = depth_core population 
    return dom unless block_given?
    dom.each { |fields| yield( fields.original, fields.depth ) }
  end

  # see Deb's NGSA2 O(MN^2)
  def layers population
    dom, front = depth_core population    
    front.map do |layer|
      layer.map { |item| item.original }
    end
  end

  protected

  def depth_core population
    classified = 0
    nondominated = []

    dom = population.map { |orig| DominanceDepth.new( orig, nil, 0, Set.new ) }
    dom.each do |p|
      dom.each_with_index do |q,qindex|
        next if p.original.object_id == q.original.object_id
        if p.original.dominates? q.original
          p.dominates.add(qindex)
        elsif q.original.dominates? p.original
          p.counter += 1 
        end
      end
      if p.counter == 0
        p.depth = 0       
        classified += 1
        nondominated.push p
      end
    end

    fronts = [nondominated.clone]
    return [dom,fronts] if @at_least != nil and classified >= @at_least

    front = 0
    until nondominated.empty?
      nextfront = []
      nondominated.each do |p|
        p.dominates.each do |qindex|
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
      fronts.push nondominated.clone unless nondominated.empty?    
      return [dom,fronts] if @at_least != nil and classified >= @at_least     
    end
   
    raise "Dominance: possibly cyclic dominance found" unless nil == dom.detect {|i| i.depth == nil }
    [dom,fronts]
  end

end

