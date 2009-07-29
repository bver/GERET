
require 'set'
require 'lib/mapper_base'

module Operator

  # Two-points LHS  (Left Hand Side) structure-preserving GE crossover operator.
  # It uses track_support information collected during genotype-phenotype mapping.
  # See http://ieeexplore.ieee.org/xpl/freeabs_all.jsp?arnumber=1555012
  class CrossoverLHS

    # Create a new crossover facility with the default attribute values.
    def initialize
      @random = Kernel
    end

    # The source of randomness, used for calling "random.rand( limit )", defaulting to 'Kernel' class.
    attr_accessor :random

    # Take parent1, parent2 genotypes and produce [offspring1, offspring2], utilising 
    # track1 and track2 information.
    # parent1 and parent2 are regular chromosomes ie. arrays (enumerables) of numbers.
    # track1 and track2 are hints for splitting points obtained from Mapper::Base#track_support.
    def crossover( parent1, parent2, track1, track2 )

      hash1 = {}
      track1.each do |node| 
        choices = hash1.fetch( node.symbol, [] )
        choices.push node
        hash1[node.symbol] = choices 
      end
      hash2 = {}
      track2.each do |node| 
        choices = hash2.fetch( node.symbol, [] )
        choices.push node
        hash2[node.symbol] = choices 
      end

      symbols = Set.new( hash1.keys ).intersection( hash2.keys ) # use only symbols present in both tracks
      sym = symbols.to_a.sort[ @random.rand( symbols.size ) ] # select a random one

      choices1 = hash1[ sym ]
      choice1 = choices1[ @random.rand( choices1.size ) ]
      choices2 = hash2[ sym ]
      choice2 = choices2[ @random.rand( choices2.size ) ]

      part1 = parent1[ choice1.from .. choice1.to ]
      part2 = parent2[ choice2.from .. choice2.to ]
      offspring1 = parent1.clone
      offspring2 = parent2.clone
      offspring1[ choice1.from .. choice1.to ] = part2
      offspring2[ choice2.from .. choice2.to ] = part1
      return offspring1, offspring2

    end

  end 

end # Operator

