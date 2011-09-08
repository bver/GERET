
begin
  
  id = ARGV.first

  $stdin.each_line do |line|
    puts id + ' ' + line.strip
    $stdout.flush   
    puts id + ' ' + line.strip
    $stdout.flush
  end

rescue
end

