#!/usr/bin/ruby

awhile = ARGV.first.to_f

(0...10).each do |i|
  puts "out[#{awhile}]=#{i}"
  $stdout.flush
  sleep awhile
end

