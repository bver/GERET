#!/usr/bin/ruby

#http://stackoverflow.com/questions/930989/is-there-a-simple-method-for-checking-whether-a-ruby-io-instance-will-block-on-re 

pipes = [ IO.popen( './produce.rb 4' ), 
          IO.popen( './produce.rb 3' ), 
          IO.popen( './produce.rb 6' ) ]

until pipes.empty? do
  ready = select( pipes, nil, nil, 0 )
  if ready.nil?
    puts "not ready, reading #{pipes.size} pipes"
  else
    ready.first.each do |pipe| 
      out = pipe.gets 
      if out.nil?
        pipe.close
        pipes.delete pipe
        puts 'pipe ended.'
        next
      end
      puts out 
    end
  end
  sleep 0.2
end

puts 'all pipes ended.'

