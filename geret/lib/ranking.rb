
module Selection

# Linear ranking assignment. Ranking sorts the population by the certain criteria and
# asign the non-negative :proportion value to each individual. The best individual obtains 
# the biggest value, the worst individual obtains the smallest one.
#
# See
# http://reference.kfupm.edu.sa/content/c/o/a_comparative_analysis_of_selection_sche_73937.pdf 
#
class Ranking

  # The result of ranking assignment for a single population member:
  #   original .. the original individual object
  #   rank .. Ranking. The best individuals obtain 0, the second ones 1, etc. Note that more individuals with the same
  #           (fitness) criterion value can share the same rank value.
  #   proportion = min + (max-min) * (N-rank)/N
  #   index .. index (order) in the original population. 
  RankedFields = Struct.new( 'RankedFields', :original, :rank, :proportion, :index )

  # Initialize the ranker. See attributes and Ranking#rank method.
  def initialize order_by=nil, direction=nil, &block 
    set_order( order_by, direction, block )
    @max = 1.1
    @min = 2.0 - @max
  end

  # The :proportion value of the best individual. Default is 0.9
  attr_accessor :max

  # The :proportion value of the worst individual. Default is 1.1
  attr_accessor :min

  # The symbol used as the sorting key. The value for ordering is retireved by calling: 
  #   individual.send(order_by) 
  attr_reader :order_by

  # The sorting direction. Expected values are: :maximize, :minimize. 
  attr_reader :direction  

  # If the block was given to the constructor, calls 
  #   { |original, rank, proportion| ... }
  # for each population and returns the population container.
  # Othervise, returns the array of the RankedFields structures, one for each population member.
  def rank population
    ranked = population.map { |orig| RankedFields.new orig }
    raise "Ranking: empty population" if ranked.empty?
    ranked.each_with_index { |individual, i| individual.index = i }
    ranked.sort! { |a,b| @order.call( a.original, b.original ) }

    rank = 0
    ranked.each_with_index do |individual, index|
      individual.rank = rank
      break if index == ranked.size-1
      rank += 1 unless 0 == @order.call( individual.original, ranked[index+1].original )
    end

    min = @min.to_f
    amplitude = @max.to_f-min
    rank = rank==0 ? 1.0 : rank.to_f
    ranked.each { |individual| individual.proportion = min+amplitude*(rank-individual.rank)/rank }
 
    if block_given?
      ranked.each { |r| yield( population[r.index], r.rank, r.proportion ) }
      return population
    else
      return ranked
    end
  end

  # Set the order_by attribute.
  def order_by= order_by
    set_order( order_by, @direction, nil )   
  end

  # Set the direction attribute.
  def direction= direction
    set_order( @order_by, direction, nil )  
  end

  protected

  def set_order( order_by, direction, block )
    if block.nil? 
      @order_by = order_by  
      @direction = direction
      if order_by.nil?
        @order = proc {|a,b| a <=> b }
      else
        case direction
          when :maximize, nil
            @order = proc {|a,b| b.send(order_by) <=> a.send(order_by) }                
            @direction = :maximize
          when :minimize
            @order = proc {|a,b| a.send(order_by) <=> b.send(order_by) }
          else
            raise "Ranking: unsupported direction argument"
        end
      end
    else
      @order = block
      @order_by = nil
      @direction = nil
    end
  end

end

end # Selection

