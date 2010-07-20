
require 'lib/abnf_parser'
require 'lib/abnf_tokenizer'
require 'lib/validator'

module Abnf

# This subclass of Mapper::Grammar parses the ABNF syntax loaded from the file.
class FileLoader < Mapper::Grammar

  # Load the file when creating the instance. If the optional fname argument is ommited, 
  # do nothing.
  # This class does not validate grammar (see Validator.analyze_all). If you want your grammer validated,
  # use the subclass Abnf::File.
  def initialize fname=nil
    grammar = load fname
    super( grammar, grammar.start_symbol )
  end

  # The name of the ABNF syntax file.
  attr_reader :filename

  # Load a new ABNF syntax file (previous grammar will be forgotten).  
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

# This helper class parses the ABNF syntax loaded from the file and performs Validator.analyze_all. 
class File < FileLoader

  protected

  def load fname
    Validator.analyze_all super(fname)
  end

end

end # Abnf

