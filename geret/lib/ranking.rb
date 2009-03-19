
class Ranking

  RankedIndividual = Struct.new( 'RankedIndividual', :original, :rank, :proportion, :index )

  def initialize orderBy
    @orderBy = if orderBy.kind_of? Proc 
                 orderBy
               else
                 proc {|a,b| b.send(orderBy) <=> a.send(orderBy) }                
               end
    @max = 1.1
    @min = 2.0 - @max
  end

  attr_accessor :max, :min

  def rank population
    ranked = population.map { |orig| RankedIndividual.new orig }
    ranked.each_with_index {|individual, i| individual.index = i }
    ranked.sort! {|a,b| @orderBy.call( a.original, b.original ) }

    rank = 0
    ranked.each_with_index do |individual, index|
      individual.rank = rank
      break if index == ranked.size-1
      rank += 1 unless 0 == @orderBy.call( individual.original, ranked[index+1].original )
    end

    min = @min.to_f
    amplitude = @max.to_f-min
    rank = rank.to_f
    ranked.each { |individual| individual.proportion = min+amplitude*(rank-individual.rank)/rank }
   
#    ranked.each_with_index do |individual, index|
#      individual.proportion = @min+(@max-@min)*(rank-individual.rank)/rank
      #individual.proportion = @min+(@max-@min)*(ranked.size-index-1)/(ranked.size-1.0)
      #individual.rank = index   
#    end

    if block_given?
      ranked.each {|r| yield( population[r.index], r.rank, r.proportion ) }
      population
    else
      ranked.sort {|a,b| a.index <=> b.index }
    end
  end
end


