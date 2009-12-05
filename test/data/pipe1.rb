#!/usr/bin/ruby

begin
  
  id = ARGV.first

  $stdin.each_line do |line|
    puts id + ' ' + line.strip
    $stdout.flush
  #  sleep 0.1
  end

rescue
end

