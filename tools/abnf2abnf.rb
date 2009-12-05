#!/usr/bin/ruby

require 'lib/abnf_file'
require 'lib/abnf_renderer'

abort "use:\n #$0 some.abnf > canonical.abnf\n" unless ARGV.size==1

begin

  grammar = Abnf::File.new ARGV[0]
  output = Abnf::Renderer.canonical( grammar )
  puts output

rescue => msg
  abort msg
end

