
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
    def initialize( ary=nil, recursive=nil )
      super ary unless ary.nil? 
      @recursivity = recursive
    end 

    def deep_copy
      alt = map {|t| Token.new( t.type, t.data, t.depth ) } 
      RuleAlt.new( alt, @recursivity )
    end

    attr_accessor :recursivity
  end
 
  class Rule < Array
    def initialize( ary=nil, recursive=nil )
      super ary unless ary.nil?
      @recursivity = recursive
    end 

    def deep_copy
      rule = map {|r| r.deep_copy } 
      Rule.new( rule, @recursivity )
    end

    attr_accessor :recursivity   
  end

end

