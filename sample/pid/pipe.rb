#!/usr/bin/ruby

abort "use:\n #$0 ID data.csv\n" unless ARGV.size==2
id, csv = ARGV

SRPhen = "#{File.dirname(__FILE__)}/phen.c"
SRMain = "#{File.dirname(__FILE__)}/main.c"
program = "/tmp/sr_source_#{id}.c"
datafile = "/tmp/sr_data_#{id}.bin"

data = ''
dim = 0
all = IO.readlines( csv ) 
all.each do |line|
  row = line.split /[,;\s]+/ 
  row.each { |value| data += [value.to_f].pack('d') }
  raise "number of values on row is not constant across the data file" if dim != 0 and dim != row.size
  dim = row.size
end
File.open( datafile, "w" ) { |f| f.puts data }

#abort "stop"

phenotype = IO.read SRPhen
main = IO.read SRMain 

code = ''
$stdin.each do |line|
 
  if /MARKER/ =~ line

    source = main.gsub( /PHENOTYPES/, code ) 
    File.open( program, "w" ) { |f| f.puts source }

    puts %x"tcc -run #{program} #{datafile} #{all.size} #{dim}" 
    $stdout.flush

    code = ''
  else
    code += phenotype.gsub( /PHENOTYPE/, line.strip )
  end

end

