#!/usr/bin/ruby

require 'ant'

abort "use:\n #$0 ant_code.rb\n" unless ARGV.size==1

code = IO.read ARGV[0] 

ant = Ant.new
10.times do { puts ant.show_scene ; ant.move }


