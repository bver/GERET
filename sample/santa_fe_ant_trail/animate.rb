#!/usr/bin/ruby
$: << 'sample/santa_fe_ant_trail'
require 'ant'

abort "use:\n #$0 ant_code.rb\n" unless ARGV.size==1

code = IO.read ARGV[0] 
ant = Ant.new

while ant.steps < Ant::MaxSteps 
  eval code
  puts ant.show_scene 
  puts "food items consumed: #{ant.consumed_food}"
  puts "steps elapsed: #{ant.steps}" 
  $stdin.gets
end



