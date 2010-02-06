
require 'lib/semantic_types'

module Semantic

  class AttrEdge < Struct.new( :dependencies, :result, :func, :age )
    def is_executable? 
      ( self.dependencies.detect { |d| d.kind_of? AttrKey } ).nil?
    end
  end

  class Edges < Array
  end

end

