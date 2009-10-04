#!/usr/bin/ruby

AntLib = "#{File.dirname(__FILE__)}/ant.c"
AntMain = "#{File.dirname(__FILE__)}/ant_evaluate.c"

abort "use:\n #$0 ID\n" unless ARGV.size==1
main = IO.read AntMain 
lib = IO.read AntLib
program = "/tmp/tcc_ant_source_#{ARGV[0]}.c"

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

