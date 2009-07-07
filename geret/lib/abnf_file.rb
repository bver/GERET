
require 'lib/abnf_parser'
require 'lib/abnf_tokenizer'

module Abnf

# This subclass of Mapper::Grammar parses the ABNF syntax loaded from the file.
class File < Mapper::Grammar

  # Load the file when creating the instance, if the optional fname argument is ommited, 
  # do nothing.
  def initialize fname=nil
    grammar = load fname
    super( grammar, grammar.start_symbol )
  end

  # The name of the ABNF syntax file.
  attr_reader :filename

  # Load a new ABNF syntax file, the previous content will be forgotten.  
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

end # Abnf

