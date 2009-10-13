
require 'set'
require 'lib/grammar'

module Mapper

  # Utilities for Mapper::Grammar validation.
  # 
  class Validator

    # Check the left hand sides of all rules for the presence of unused symbols.
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

    # Check the right hand sides of all rules for the presence of undefined symbols.
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

    # Compute Rule#recursivity and RuleAlt#recursivity attributes for the Mapper::Grammar syntax tree.
    # 
    # The symbol S may have one of three possible recursivity values:
    #   grammar[S].recursivity == :terminating ... all possible expansions of S lead to terminal symbols (literals) ( S -> T1 | T2 )
    #   grammar[S].recursivity == :infinite  ... all possible expansions of S lead to infinite syntax loops ( S -> R, R -> S )
    #   grammar[S].recursivity == :cyclic ... expansions of S sometimes terminates, but some of them are recursive ( S -> R, R -> S | T ) 
    #   
    # This method is utilised in the sensitive initialisation (Mapper::Generator) and for general classification of Grammars:
    #   grammar.start_symbol.recursivity == :terminating ... trivial grammars, producing only phenotypes of intrinsically limited sizes 
    #   grammar.start_symbol.recursivity == :infinite ... a grammar unusable for mapping 
    #                                                    (Mapper::Base#phenotype would not terminate in a finite time).
    #   grammar.start_symbol.recursivity == :cyclic ... a typical grammar producing nontrivial phenotypes 
    #                                                  (intrinsically unlimited in size) 
    #   
    # Note: The termination of mapping with :cyclic grammars is guaranteed by external means (Mapper::Base#wraps_to_fail, Mapper::Base#wraps_to_fading)
    # 
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

    # For all grammar's symbols fill :sn_altering attributes.
    # These attributes (see Grammar#sn_altering) are used by MutationStructural and MutationNodal classes (see).
    # Note the grammar argument is altered (no grammar.clone is done)
    def Validator.analyze_sn_altering grammar  
      
      grammar.each_value do |rule|

        rule.sn_altering = :nodal
        subsyms = nil
        rule.each do |alts|
          sub = alts.find_all {|token| token.type == :symbol }
          subsyms = sub if subsyms.nil?
          next if subsyms == sub
          rule.sn_altering = :structural
          break
        end
      end

      grammar
    end

  protected 

    def Validator.recursivity_over container
      result = Set.new
      container.each { |item| result.add( item.recursivity ) }
      result.to_a
    end
    
  end #Validator

end #Mapper

