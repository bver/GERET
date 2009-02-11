

require 'lib/mapper_types'

module Abnf
  
  class Parser
    def initialize
      @transitions = {
        :start =>    {
                       :symbol => proc {|g,t| g.rule_name=t.data; return :equals },
                       :crlf => proc { return :start; }
                     },
        :equals =>   {
                       :equals => proc {|g,t| g.start_alt; return :elements }
                     },
        :elements => {
                       :symbol => proc {|g,t| g.push_token=t; return :elements },
                       :literal => proc {|g,t| g.push_token=t; return :elements },
                       :slash =>  proc {|g,t| g.start_alt; return :elements },
                       :newline => proc {|g,t| g.store_rule; return :start }
                     },
      }

    end

    def parse stream
      @gram = Mapper::Grammar.new 
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
    
    def rule_name=( symbol )
      @rule_name = symbol
      @rule = Mapper::Rule.new
    end

    def start_alt
      @rule.push Mapper::RuleAlt.new
    end

    def push_token=( token )
      @rule.last.push token 
    end

    def store_rule
      @gram[ @rule_name ] = @rule
    end
  end

end




