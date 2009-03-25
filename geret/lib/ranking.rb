
class Ranking

  RankedFields = Struct.new( 'RankedFields', :original, :rank, :proportion, :index )

  def initialize orderBy=nil, direction=:maximize, &block 
    @orderBy = if block.nil? 
                 case direction
                 when :maximize
                   proc {|a,b| b.send(orderBy) <=> a.send(orderBy) }                
                 when :minimize
                   proc {|a,b| a.send(orderBy) <=> b.send(orderBy) }
                 else
                   raise "Ranking: unsupported direction argument"
                 end
               else
                 block
               end
    @max = 1.1
    @min = 2.0 - @max
  end

  attr_accessor :max, :min

  def rank population
    ranked = population.map { |orig| RankedFields.new orig }
    raise "Ranking: empty population" if ranked.empty?
    ranked.each_with_index { |individual, i| individual.index = i }
    ranked.sort! { |a,b| @orderBy.call( a.original, b.original ) }

    rank = 0
    ranked.each_with_index do |individual, index|
      individual.rank = rank
      break if index == ranked.size-1
      rank += 1 unless 0 == @orderBy.call( individual.original, ranked[index+1].original )
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

end


