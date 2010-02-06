
require 'lib/semantic_types'

module Semantic

  class AttrEdge < Struct.new( :dependencies, :result, :func, :age )
    
    def is_executable? 
      ( dependencies.detect { |d| d.kind_of? AttrKey } ).nil?
    end

    def exec_func
      # raise "Semantic::AttrEdge is_executable? check fails" unless is_executable?
      func.call( dependencies )
    end

  end

  class Edges < Array
  end

end

