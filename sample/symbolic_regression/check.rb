#!/usr/bin/ruby

# this script checks the produced expressions

y, v1, v2, v3, v4, v5 = [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]

$stdin.each_line do |line|
  x = line.strip.split( /,/ ).map { |v| v.to_f }
  
  #phenotype
  v2 = v3; v3 = (x[1]+x[2]+x[2]+x[1]+x[2]+x[2]+v5+x[2]+x[2]); v5 = x[2]+x[2]+x[2];  y = v3-v2;

  puts "#{y},#{x[0]},#{x[1]},#{x[2]}"
end

