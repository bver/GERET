#!/usr/bin/ruby

id = ARGV.first

out = []
$stdin.each_line do |line|
  out << id + ' ' + line.strip unless /BATCH/ =~ line

  if /BATCH/ =~ line or out.size >= 8
    out.each {|line| puts line}
    out = []
    $stdout.flush
  end
end

