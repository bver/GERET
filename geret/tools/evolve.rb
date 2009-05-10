#!/usr/bin/ruby -w 
#!/usr/local/bin/ruby19/ruby -d

require 'lib/geret'

begin
  argv = ARGV.clone
  ConfigYaml.remove_options! ARGV
  abort "use:\n #$0 [options] config.yaml\n" unless ARGV.size==1
  config = ConfigYaml.new ARGV.first
  config = ConfigYaml.parse_options( argv, config )

  algorithm = config.factory('algorithm')
  report = algorithm.setup config
  puts report.output
  $stdout.flush 

  until algorithm.finished?
    report = algorithm.step
    puts report.output
    $stdout.flush
  end

  report = algorithm.teardown
  puts report.output 

rescue Interrupt => msg   
  puts "\n#{$0} INTERRUPTED: '#{msg}'"
  algorithm.teardown

rescue => msg
  abort msg.to_s
end

