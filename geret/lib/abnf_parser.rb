
require 'lib/mapper_types'
include Mapper

module Abnf
  
  class Parser
    Slot = Struct.new( :name, :rule, :end )
   
    def initialize
      @transitions = {
        :start =>    {
                       :symbol => proc {|g,t| g.rule=t; :equals },
                       :newline => proc { :start },
                       :comment => proc { :start }
                     },
        :equals =>   {
                       :equals => proc { :elements },
                       :eq_slash => proc {|g,t| g.retype=:incremental; :elements },
                       :comment => proc { :equals },  
                       :space => proc { :equals } 
                     },
        :elements => {
                       :symbol => proc {|g,t| g.tok=t;:elements },
                       :literal => proc {|g,t| g.tok=t; :elements },
                       :slash =>  proc {|g,t| g.alt; :elements },
                       :newline => proc {|g,t| :next_rule },
                       :seq_begin => proc {|g,t| g.group=t; :elements },
                       :seq_end => proc {|g,t| g.store=t; :elements },                    
                       :opt_begin => proc {|g,t| g.opt=t; :elements },
                       :opt_end => proc {|g,t| g.store=t; :elements },                    
                       :comment => proc { :elements },  
                       :space => proc { :elements }, 
                       :eof => proc { |g,t| g.retype=:eof; g.store=t; :stop }                    
                     },
        :next_rule => {
                       :symbol => proc {|g,t|  g.store=t; g.rule=t; :equals },
                       :comment => proc { :next_rule },                      
                       :space => proc { :elements },
                       :newline => proc { :next_rule },
                       :eof => proc { |g,t| g.retype=:eof; g.store=t; :stop }
                      },
      }

    end

    def parse stream
      @stack = []
      @iv = 0
      @gram = Grammar.new 
      state = :start
 
      stream.each do |token|
        trans = @transitions.fetch state
        action = trans.fetch( token.type, nil )
        raise "unexpected token #{token.type} when in #{state}" if action.nil?
        state = action.call( self, token )
      end
      @gram
    end
    
    protected
    
    def rule=( token )
      @stack.push Slot.new( token.data, Rule.new, :symbol )
      alt
    end

    def retype=( arg )
      @stack.last.end = arg if @stack.last.end == :symbol  
    end

    def group=( token )
      name = @stack.last.name + "_grp#{@iv+=1}"
      self.tok = Token.new( :symbol, name ) 
      @stack.push Slot.new( name, Rule.new, :seq_end )
      alt
    end

    def opt=( token )
      name = @stack.last.name + "_opt#{@iv+=1}"
      self.tok = Token.new( :symbol, name ) 
      @stack.push Slot.new( name, Rule.new, :opt_end )
      alt
      self.tok = Token.new( :literal, '' )
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
      when :incremental
        orig_rule = @gram.fetch( slot.name, nil )
        raise "Parser: incremental alternative: '#{slot.name}' must be defined first" if orig_rule.nil?
        orig_rule.concat slot.rule
      when token.type
        orig_rule = @gram.fetch( slot.name, nil ) 
        raise "Parser: symbol '#{slot.name}' already defined" unless orig_rule.nil?
        @gram[ slot.name ] = slot.rule
      else
        raise "Parser: missing '#{slot.end}' token"
      end
    end
  end

end




