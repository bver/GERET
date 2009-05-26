
require 'set'
require 'lib/grammar'

module Mapper

  class Validator

    # checks the left hand sides of all rules for the presence of unused symbols.
    # (The symbol is used (referenced) if there is at least one rule using it on 
    # it's right hand side.)
    # Returns the array of all unused symbols.
    # Note it is often expected that grammar.start_symbol is returned.
    #   
    def Validator.check_unused grammar
      defs = grammar.symbols
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
      defs = grammar.symbols
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

    def Validator.analyze_recursivity grammar
      gram = grammar.deep_copy

      gram.each_value do |rule|
        rule.recursivity = :infinite
        rule.each { |alt| alt.recursivity = :infinite }
      end

      changed = true
      while changed
        changed = false
        gram.each_value do |rule|

          rule.each do |alt| 

            references = alt.find_all { |token| token.type == :symbol } 
            res = recursivity_over( references.map {|token| gram[token.data] } )
            now = if res.include? :infinite
                    :infinite
                  elsif res.include? :cyclic
                    :cyclic
                  else
                    :terminating
                  end

            changed = true if alt.recursivity != now  
            alt.recursivity = now

          end

          res = recursivity_over rule
          now = (res.size == 1) ? res.first : :cyclic 

          changed = true if rule.recursivity != now  
          rule.recursivity = now

        end
      end

      gram
    end

  protected 

    def Validator.recursivity_over container
      result = Set.new
      container.each { |item| result.add( item.recursivity ) }
      result.to_a
    end
    
  end #Validator

end #Mapper

