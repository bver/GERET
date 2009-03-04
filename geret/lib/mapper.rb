
require 'lib/grammar'
require 'lib/validator'
require 'lib/mapper_generator'

module Mapper

  class DepthFirst < Base
    include LocusFirst
    include ExtendDepth
    include PolyIntrinsic 
  end

  class BreadthFirst < Base
    include LocusFirst
    include ExtendBreadth
    include PolyIntrinsic 
  end

  class DepthLocus < Base
    include LocusGenetic
    include ExtendDepth
    include PolyIntrinsic 
  end

  class BreadthLocus < Base
    include LocusGenetic
    include ExtendBreadth
    include PolyIntrinsic 
  end

  class DepthBucket < Base
    include LocusFirst
    include ExtendDepth
    include PolyBucket 
  end

  class BreadthBucket < Base
    include LocusFirst
    include ExtendBreadth
    include PolyBucket 
  end
 
end # Mapper
