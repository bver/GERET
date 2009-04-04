
require 'lib/abnf_parser'
require 'lib/abnf_tokenizer'

class AbnfFile < Mapper::Grammar

  def initialize filename
    input = IO.read( filename )
    stream = Abnf::Tokenizer.new.tokenize( input )
    grammar = Abnf::Parser.new.parse( stream )
    super( grammar, grammar.start_symbol )
  end

end

