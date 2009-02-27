#!/usr/bin/ruby

require 'lib/abnf_parser'
require 'lib/abnf_tokenizer'
require 'lib/validator'

###

abort "use:\n #$0 some.abnf > canonical.abnf\n" unless ARGV.size==1

begin

  input = IO.read( ARGV[0] )
  stream = Abnf::Tokenizer.new.tokenize( input )
  grammar = Abnf::Parser.new.parse( stream )
  
  puts "start symbol: <#{grammar.start_symbol}>"
  undefined = Mapper::Validator.check_undefined grammar
  puts "undefined symbols: " + undefined.map{|s| "<#{s}>"}.join(', ')
  unused = Mapper::Validator.check_unused grammar
  puts "not referenced symbols: " + unused.map{|s| "<#{s}>"}.join(', ')

rescue => msg
  abort msg
end

