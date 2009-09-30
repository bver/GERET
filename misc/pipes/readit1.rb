#!/usr/bin/ruby

#http://stackoverflow.com/questions/930989/is-there-a-simple-method-for-checking-whether-a-ruby-io-instance-will-block-on-re 
class IO
  def ready_for_read?
    result = IO.select([self], nil, nil, 0)
    result && (result.first.first == self)
  end
end


pipe = IO.popen( './produce.rb 4' )

loop do
  if pipe.ready_for_read?
    puts pipe.readline
    #break if pipe.eof? 
  else
    puts 'not ready'
  end
  sleep 0.3
end

pipe.close
puts 'ended.'

