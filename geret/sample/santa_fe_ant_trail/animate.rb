#!/usr/bin/ruby
$: << 'sample/santa_fe_ant_trail'
require 'ant'

abort "use:\n #$0 ant_code.rb\n" unless ARGV.size==1

code = IO.read ARGV[0] 
ant = Ant.new

400.times do 
  puts ant.show_scene
  eval code
  puts "food items consumed: #{ant.consumed_food}"
  $stdin.gets
end



