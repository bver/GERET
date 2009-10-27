#!/usr/bin/ruby

id = ARGV.first

out = []
$stdin.each_line do |line|
  if /BATCH/ =~ line
    out.each {|line| puts line}
    out = []
    $stdout.flush   
  else
    out << id + ' ' + line.strip
  end
end

