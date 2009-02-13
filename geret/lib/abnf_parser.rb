
require 'lib/mapper_types'
include Mapper

module Abnf
  
  class Parser
    Slot = Struct.new( :name, :rule, :end )
   
    def initialize
      @transitions = {
        :start =>    {
                       :symbol => proc {|g,t| g.rule=t; :equals },
                       :newline => proc { :start }
                     },
        :equals =>   {
                       :equals => proc { :elements },
                       :eq_slash => proc {|g,t| g.incr; :elements }
                     },
        :elements => {
                       :symbol => proc {|g,t| g.tok=t;:elements },
                       :literal => proc {|g,t| g.tok=t; :elements },
                       :slash =>  proc {|g,t| g.alt; :elements },
                       :newline => proc {|g,t| g.store=t; :start },
                       :seq_begin =>proc {|g,t| g.group=t; :elements },
                       :seq_end =>proc {|g,t| g.store=t; :elements }                    
                     },
      }

    end

    def parse stream
      @stack = []
      @iv = 0
      @gram = Grammar.new 
      state = :start
 
      stream.each do |token|
        next if token.type == :space or token.type == :comment
        trans = @transitions.fetch state
        action = trans.fetch( token.type, nil )
        raise "unexpected token #{token.type}" if action.nil?
        state = action.call( self, token )
      end
      @gram
    end
    
    protected
    
    def rule=( token )
      @stack.push Slot.new( token.data, Rule.new, :newline )
      alt
    end

    def incr
      @stack.last.end = :incremental
    end

    def group=( token )
      name = @stack.last.name + "_grp#{@iv+=1}"
      self.tok = Token.new( :symbol, name ) 
      @stack.push Slot.new( name, Rule.new, :seq_end )
      alt
    end
   
    def alt
      @stack.last.rule.push RuleAlt.new
    end

    def tok=( token )
      @stack.last.rule.last.push token 
    end

    def store=( token )
      slot = @stack.pop
      case slot.end
      when token.type
        @gram[ slot.name ] = slot.rule
      when :incremental
        orig_rule = @gram.fetch( slot.name, nil )
        raise "incremental alternative: #{slot.name} must be defined first" if orig_rule.nil?
        orig_rule.concat slot.rule
      else
        raise "missing #{slot.end} token" unless token.type == slot.end
      end
    end
  end

end




