
require 'lib/abnf_parser'
require 'lib/abnf_tokenizer'

class AbnfFile < Mapper::Grammar

  def initialize fname=nil
    grammar = load fname
    super( grammar, grammar.start_symbol )
  end

  attr_reader :filename

  def filename=( fname )
    grammar = load fname
    clear
    update grammar
    self.start_symbol = grammar.start_symbol
  end

  protected

  def load fname
    @filename = fname
    return Grammar.new if fname.nil?

    input = IO.read( fname )
    stream = Abnf::Tokenizer.new.tokenize( input )
    return Abnf::Parser.new.parse( stream )
  end

end

