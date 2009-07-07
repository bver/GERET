
require 'set'

module Moea

# General purpose class for computing various pareto dominance metrics. It provides these types of dominance rankings:
#   * Dominance Count  - http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.12.4172&rep=rep1&type=pdf 
#   * Dominance Rank   - http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.12.4172&rep=rep1&type=pdf  
#   * Dominance Depth (NSGA), see http://ieeexplore.ieee.org/xpl/freeabs_all.jsp?arnumber=996017
#   * Pareto Strength (SPEA), see http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=934438 
#                             or https://eprints.kfupm.edu.sa/52319/1/52319.pdf 
#
# All Dominance methods assume that 
#   1. the population is the Enumerable container of individuals and 
#   2. the existence of the method individual.dominates?( other ) returning true if the individual dominates other one.
#
class Dominance
  DominanceFields = Struct.new( 'DominanceFields', :original, :rank, :dominates, :spea, :count )
  DominanceDepth = Struct.new( 'DominanceDepth', :original, :depth, :counter, :dominates )

  def initialize
    @at_least = nil
  end

  # how much individuals should be classified into Pareto Layers before the classification stops (nil means unlimited, ie. population.size)
  attr_accessor :at_least

  # Compute Dominance Rank, Dominance Count and Pareto Strength for the individual i.
  #   There are two variants: 
  #   
  #     population2 = Dominance.new.rank_count population
  #     * population2[i].original ... original population's individual
  #     * population2[i].rank (Dominance Rank) ... the number of individuals by which the individual i is dominated
  #     * population2[i].count (Dominance Count)  ... the number of individuals dominated by the individual i
  #     * population2[i].spea (Pareto Strength) ... sum of Dominance Counts of all individals dominating the individual i
  #
  #     or
  #     population2 = Dominance.new.rank_count( population ) { |original,rank,count,spea| ... }
  #       where the block is called for each individual in the population.
  #   
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

  # Compute Pareto Depth (see Deb's NGSA-II) 
  # with the complexity O(MN^2) where N is the population size and M is the number of objectives.
  # 
  #   Dominance.new.depth( population ) { |original,depth| ... }
  #   The block is called with the original population's individual and the depth value.
  #   The depth is the index of the dominance layer whose the individual is a member (see Dominance#layers)
  # 
  # The block need not to be called for individuals with the higher depth (see the at_least attribute).
  # 
  def depth population
    dom, front = depth_core population 
    return dom unless block_given?
    dom.each { |fields| yield( fields.original, fields.depth ) }
  end

  # Compute Pareto Dominance Layers (see Deb's NGSA-II)
  # with the complexity O(MN^2) where N is the population size and M is the number of objectives.
  #     layers = Dominance.new.depth( population ) 
  #     
  # The array of layers is returned. Each layer is an array of original individuals, such as:
  #   - the layers[0] contains only nondominated individuals
  #   - layers[1] contains nondominated individuals of the population1 (ie the original population without layers[0] members)
  #   - layers[2] contains nondominated individuals of the population2 (ie the population1 without layers[1] members) 
  #   ... 
  #    
  # Note the at_least attribute may limit the number of individuals classified to layers. 
  # The classification stops when layers.flatten.size >= at_least.
  # 
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

end # Moea

