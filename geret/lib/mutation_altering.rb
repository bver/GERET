
module Operator

  class MutationAltering

    def initialize( grammar, magnitude=nil )
      @grammar = grammar
      @random = Kernel
      @magnitude = magnitude
    end

    # The source of randomness, used for calling "random.rand( limit )", defaulting to 'Kernel' class.
    attr_accessor :random
   
    # The maximal possible value of the mutaton plus 1. If not specified, the maximal value over the original 
    # genotype values is used.
    attr_accessor :magnitude
   
    def mutation( orig, track )
      mutant = orig.clone
      max = @magnitude.nil? ? mutant.max+1 : @magnitude
      filtered_track = track.find_all { |node| @grammar[ node.symbol ].sn_altering == filter }
      where = @random.rand( filtered_track.size )
      index = filtered_track[where].from 
      mutant[ index ] = @random.rand( max )
      mutant
    end
   
  end

  class MutationStructural < MutationAltering
    protected
    def filter
      :structural 
    end
  end

  class MutationNodal < MutationAltering
    protected
    def filter
      :nodal
    end
  end

end # Operator

