#!/usr/bin/ruby

require 'lib/abnf_file'
require 'lib/validator'

###

abort "use:\n #$0 some.abnf > canonical.abnf\n" unless ARGV.size==1

begin

  grammar = Abnf::File.new ARGV[0]
  puts "start symbol: <#{grammar.start_symbol}>"
  undefined = Mapper::Validator.check_undefined grammar
  puts "undefined symbols: " + undefined.map{|s| "<#{s}>"}.join(', ')
  unused = Mapper::Validator.check_unused grammar
  puts "not referenced symbols: " + unused.map{|s| "<#{s}>"}.join(', ')

rescue => msg
  abort msg
end

