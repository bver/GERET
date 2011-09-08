
AdderTemplate = "#{File.dirname(__FILE__)}/template.vhdl"
AdderTestbBench = "#{File.dirname(__FILE__)}/adder_tb.vhdl"

abort "use:\n #$0 ID\n" unless ARGV.size==1
dir = "/tmp/adder_#{ARGV[0]}/"
Dir.mkdir(dir)
template = IO.read AdderTemplate
File.open( "#{dir}/adder_tb.vhdl", "w" ) { |f| f.print IO.read(AdderTestbBench) }

code = ''
$stdin.each do |line|
 
  code += line
  next unless /end rtl;/ =~ line

  source = template.gsub( /TEMPLATE/, code )
  File.open( "#{dir}/adder.vhdl", "w" ) { |f| f.puts source }
 
  puts %x"cd #{dir} && ghdl -a adder.vhdl && ghdl -a adder_tb.vhdl && ghdl -e adder_tb && ghdl -r adder_tb"
  $stdout.flush

  code = ''

end

