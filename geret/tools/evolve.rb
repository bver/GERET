#!/usr/bin/ruby -w 
#!/usr/local/bin/ruby19/ruby -d

require 'lib/geret'

abort "use:\n #$0 config.yaml\n" unless ARGV.size==1

begin
  config = ConfigYaml.new ARGV[0]

  algorithm = config.factory('algorithm')
  algorithm.setup config

  until algorithm.finished?
    report = algorithm.step
    puts report.output
  end

  report = algorithm.teardown
  puts report.output 

rescue Interrupt => msg   
  puts "\n#{$0} INTERRUPTED: '#{msg}'"
  algorithm.teardown

rescue => msg
  abort msg.to_s
end

