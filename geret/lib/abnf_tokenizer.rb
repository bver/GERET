
require 'lib/mapper_types'

module Abnf
  
  class Tokenizer

    def initialize
      @rex = [
        [ /\A\r?\n/m, :newline ],

        [ /\A[ \t\f]+/m, :space ],

        [ /\A(;[^\r\n]*\r?\n)/m, [ 
                             [ /\A;([^\r\n]*)/m, :comment ], 
                             [ /\A\r?\n/m,   :newline ] 
                           ]
        ],

        [ /\AALPHA/m, :_alpha ],
        [ /\ABIT/m, :_bit ],
        [ /\AVCHAR/m, :_vchar ],       
        [ /\ACHAR/m, :_char ],
        [ /\ACRLF/m, :_crlf ],
        [ /\ACR/m, :_cr ],
        [ /\ALF/m, :_lf ],
        [ /\ACTL/m, :_ctl ],
        [ /\ADIGIT/m, :_digit ],
        [ /\ADQUOTE/m, :_dquote ],
        [ /\AHEXDIG/m, :_hexdig ],
        [ /\AHTAB/m, :_htab ],
        [ /\ALWSP/m, :_lwsp ],
        [ /\AWSP/m, :_wsp ],
        [ /\ASP/m, :_sp ],
        [ /\AOCTET/m, :_octet ],

        [ /\A([A-Za-z][\w\-]*)/m, :symbol ],
        [ /\A<([A-Za-z][\w\-]*)>/m, :symbol ],

        [ /\A"([^"]*?)"/m, :literal ],

        [ /\A%b([01][01\-\.]*)/m, [
                                   [ /\A([01]+)/m, :entity_bin ],
                                   [ /\A\-/m, :dash ],
                                   [ /\A\./m, :dot ]                            
                                 ]
        ],

        [ /\A%d([\d][\d\-\.]*)/m, [
                                   [ /\A(\d+)/m, :entity_dec ],
                                   [ /\A\-/m, :dash ],
                                   [ /\A\./m, :dot ]                            
                                 ]
        ],

        [ /\A%x([a-fA-F\d][a-fA-F\d\-\.]*)/m, [
                                               [ /\A([a-fA-F\d]+)/m, :entity_hex ],
                                               [ /\A-/m, :dash ],
                                               [ /\A\./m, :dot ]                           
                                             ]
        ],
     
        [ /\A(\d+)/m, :number ],

        [ /\A\*/m, :asterisk ],

        [ /\A=\//m, :eq_slash ],
        [ /\A=/m, :equals ],

        [ /\A\(/m, :seq_begin ],
        [ /\A\)/m, :seq_end ],

        [ /\A\[/m, :opt_begin ],
        [ /\A\]/m, :opt_end ],
       
        [ /\A\//m, :slash ]

      ]
    end

    def tokenize( text, rex=@rex )
      tokens = []
      matched = nil
      until text.empty?
        rex.each do |rule| 
          expr,extractors = rule
          matched = expr.match( text )

          next if matched.nil?
          consumed = matched[0].to_s 
          data = (matched.size>1) ? matched[1].to_s : nil
          if extractors.class == Array
            tokens.concat tokenize( data, extractors ) #recursion
          else
            tokens.push Mapper::Token.new( extractors, data )
          end
          text = text[ consumed.size...text.size ]
          break
        end
        raise "Tokenizer: unexpected tokens near '#{text.slice(0..10)}'" if matched.nil? 
      end
      tokens
    end

  end
end

