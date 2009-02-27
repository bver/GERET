
module Mapper

  class Validator

    # checks the left hand sides of all rules for the presence of unused symbols.
    # (The symbol is used (referenced) if there is at least one rule using it on 
    # it's right hand side.)
    # Returns the array of all unused symbols.
    # Note it is often expected that grammar.start_symbol is returned.
    #   
    def Validator.check_unused grammar
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
    def Validator.check_undefined grammar
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

end

