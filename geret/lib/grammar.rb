
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
      copy = Grammar.new
      copy.start_symbol = String.new @start_symbol
      each_pair {|symb, alt| copy[symb] = alt.deep_copy }
      copy 
    end

    attr_accessor :start_symbol

    # checks the left hand sides of all rules for the presence of unused symbols.
    # (The symbol is used if there is at least one rule using it on it's right hand side.)
    # Returns the array of all unused symbols.
    # Note it is often expected that grammar.start_symbol is returned.
    #   
    def Grammar.check_unused grammar
      defs = grammar.keys
      #defs.delete grammar.start_symbol
      grammar.each_value do |rule|
        rule.each do |alt|
          alt.each do |token| 
            next unless token.type == :symbol
            next unless defs.include? token.data 
            defs.delete token.data 
          end
        end
      end
      defs
    end

    # checks the right hand sides of all rules for the presence of undefined symbols.
    # (The symbol is defined if there is exactly one rule where the symbol is used 
    # on the left hand side.)
    # Returns the array of all undefined symbols.
    #
    def Grammar.check_undefined grammar
      undefs = []
      defs = grammar.keys
      grammar.each_value do |rule|
        rule.each do |alt|
          alt.each do |token| 
            next unless token.type == :symbol
            next if defs.include? token.data 
            undefs.push token.data 
          end
        end
      end
      undefs
    end   
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

