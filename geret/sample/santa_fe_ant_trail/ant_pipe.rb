#!/usr/bin/ruby

AntLib = "#{File.dirname(__FILE__)}/ant.c"

abort "use:\n #$0 ant_main.c ID\n" unless ARGV.size==2
main = IO.read ARGV[0]
lib = IO.read AntLib
program = "/tmp/tcc_ant_source_#{ARGV[1]}.c"

code = ''
$stdin.each do |line|
 
  if /MARKER/ =~ line
    source = main.gsub( /PHENOTYPE/, code )
    File.open( program, "w" ) { |f| f.puts lib+source }

    puts %x"tcc -run #{program}"
    $stdout.flush

    code = ''
  else
    code += line
  end

end

