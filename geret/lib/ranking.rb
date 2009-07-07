
module Selection

class Ranking

  RankedFields = Struct.new( 'RankedFields', :original, :rank, :proportion, :index )

  def initialize order_by=nil, direction=nil, &block 
    set_order( order_by, direction, block )
    @max = 1.1
    @min = 2.0 - @max
  end

  attr_accessor :max, :min
  attr_reader :order_by, :direction 

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

  def order_by= order_by
    set_order( order_by, @direction, nil )   
  end

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

