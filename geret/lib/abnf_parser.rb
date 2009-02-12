
require 'lib/mapper_types'
include Mapper

module Abnf
  
  class Parser
    Slot = Struct.new( "Slot", :name, :rule, :end )
   
    def initialize
      @transitions = {
        :start =>    {
                       :symbol => proc {|g,t| g.rule=t; return :equals },
                       :newline => proc { return :start; }
                     },
        :equals =>   {
                       :equals => proc { return :elements }
                     },
        :elements => {
                       :symbol => proc {|g,t| g.tok=t; return :elements },
                       :literal => proc {|g,t| g.tok=t; return :elements },
                       :slash =>  proc {|g,t| g.alt; return :elements },
                       :newline => proc {|g,t| g.store=t; return :start },
                       :seq_begin =>proc {|g,t| g.group=t; return :elements },
                       :seq_end =>proc {|g,t| g.store=t; return :elements }                    
                     },
      }

    end

    def parse stream
      @stack = []
      @iv = 0
      @gram = Grammar.new 
      state = :start
 
      until stream.empty?
        token = stream.shift
        next if token.type == :space or token.type == :comment

        trans = @transitions.fetch state
        action = trans.fetch( token.type, nil )
        raise "unexpected token #{token.type}" if action.nil?
        state = action.call( self,token )
      end
      @gram
    end
    
    protected
    
    def rule=( token )
      @stack.push Slot.new( token.data, Rule.new, :newline )
      alt
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
      raise "missing #{slot.end} token" unless token.type == slot.end
      @gram[ slot.name ] = slot.rule
    end
  end

end




