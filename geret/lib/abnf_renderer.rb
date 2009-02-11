
require 'lib/mapper_types'

module Abnf
  
  class Renderer

    def Renderer.canonical grammar
      res = ''
      grammar.each_pair do |name, rule|
        rule.each do |alt|
          res += ( name + ' =' )
          res += '/' if alt != rule.first
          alt.each do |token|
            res += ' ';
            case token.type
            when :literal
              res += ('"' + token.data + '"')
            when :symbol
              res += token.data
            else
              raise "unsupported token.type=#{token.type}"
            end
          end
          res += "\n"
        end
        res += "\n"
      end
      res
    end

  end

end

