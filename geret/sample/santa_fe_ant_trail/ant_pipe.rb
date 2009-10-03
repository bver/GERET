#!/usr/bin/ruby

AntLib = "#{File.dirname(__FILE__)}/ant.c"
ProgramSource = '/tmp/tcc_ant_source.c'

abort "use:\n #$0 ant_main.c\n" unless ARGV.size==1
main = IO.read ARGV[1]
lib = IO.read AntLib

code = ''
$stdin.each do |line|
 
  if /MARKER/ =~ line
    source = main.gsub( /PHENOTYPE/, code )
    File.open( ProgramSource, "w" ) { |f| f.puts lib+source }

    puts %x"tcc -run #{ProgramSource}"
    $stdout.flush

    code = ''
  end

  code += line

end

