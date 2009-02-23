#!/usr/bin/ruby

require 'lib/abnf_parser'
require 'lib/abnf_tokenizer'
require 'lib/abnf_renderer'

###

abort "use:\n #$0 some.abnf > canonical.abnf\n" unless ARGV.size==1

begin

  input = IO.read( ARGV[0] )
  stream = Abnf::Tokenizer.new.tokenize( input )
  grammar = Abnf::Parser.new.parse( stream )
  
  undefined = Abnf::Parser.check_undefined grammar
  puts ";undefined symbols: " + undefined.map{|s| "<#{s}>"}.join(', ') unless undefined.empty?
  unused = Abnf::Parser.check_unused grammar
  puts ";unused symbols: " + unused.map{|s| "<#{s}>"}.join(', ') unless unused.empty?
  
  output = Abnf::Renderer.canonical( grammar )
  puts output

rescue => msg
  abort msg
end

