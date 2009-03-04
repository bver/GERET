
require 'lib/grammar'
require 'lib/validator'
require 'lib/mapper_generator'

module Mapper

  class DepthFirst < Generator
    include LocusFirst
    include ExtendDepth
    include PolyIntrinsic 
  end

  class BreadthFirst < Generator
    include LocusFirst
    include ExtendBreadth
    include PolyIntrinsic 
  end

  class DepthLocus < Generator
    include LocusGenetic
    include ExtendDepth
    include PolyIntrinsic 
  end

  class BreadthLocus < Generator
    include LocusGenetic
    include ExtendBreadth
    include PolyIntrinsic 
  end

  class DepthBucket < Generator
    include LocusFirst
    include ExtendDepth
    include PolyBucket 
  end

  class BreadthBucket < Generator
    include LocusFirst
    include ExtendBreadth
    include PolyBucket 
  end
 
end # Mapper
