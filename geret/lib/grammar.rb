
module Mapper

  Token = Struct.new( :type, :data, :depth )
  
  class Grammar < Hash
    def initialize( src=nil, start=nil )
      update src unless src.nil?

      if start.nil? 
        @start_symbol = src.start_symbol if src.class == Grammar
      else
        @start_symbol = start
      end
    end

    attr_accessor :start_symbol
  end

  class Rule < Array
  end

  class RuleAlt < Array
    def deep_copy
      map {|t| Token.new(t.type,t.data) } 
    end
  end

end
