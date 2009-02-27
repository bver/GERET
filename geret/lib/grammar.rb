
module Mapper

  Token = Struct.new( :type, :data, :depth )
  
  class Grammar < Hash
    def initialize( src=nil, start=nil )
      super()
      update src unless src.nil?

      if start.nil? 
        @start_symbol = src.start_symbol if src.class == Grammar
      else
        @start_symbol = start
      end
    end

    def deep_copy
      copy = Grammar.new( nil, @start_symbol )
      each_pair {|symb, alt| copy[symb] = alt.deep_copy }
      copy 
    end

    attr_accessor :start_symbol

  end

  class RuleAlt < Array
    def deep_copy
      map {|t| Token.new( t.type, t.data, t.depth ) } 
    end
  end
 
  class Rule < Array
    def deep_copy
      map {|r| r.deep_copy } 
    end
  end

end

