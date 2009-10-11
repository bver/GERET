#!/usr/bin/ruby

AntLib = "#{File.dirname(__FILE__)}/ant.c"
ProgramSource = '/tmp/tcc_ant_source.c'

abort "use:\n #$0 phenotype_code.c ant_main.c\n" unless ARGV.size==2
code = IO.read ARGV[0]
main = IO.read ARGV[1]
lib = IO.read AntLib

main.gsub!( /PHENOTYPE/, code ) 
File.open( ProgramSource, "w" ) { |f| f.puts lib+main }

exec "tcc -run #{ProgramSource}"

