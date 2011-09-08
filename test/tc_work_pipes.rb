
$LOAD_PATH << '.'

require 'rbconfig'
require 'test/unit'
require 'lib/work_pipes'

include Util

WPop = Struct.new( 'WPop', :phenotype, :parse )
WPopFT = Struct.new( 'WPopFT', :from, :to, :to2 )
class WPopBatch < WPop
  def WPopBatch.batch_mark
    'BATCH'
  end
end
class WPopBatchNotSet < WPop
  def WPopBatchNotSet.batch_mark
    nil 
  end
end

class TC_WorkPipes  < Test::Unit::TestCase
 
  def setup
    @dir = "#{File.dirname(__FILE__)}/data/"
    @ruby = File.join( RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'] )
  end

  def test_basic
    pipes = WorkPipes.new [ "#{@ruby} #{@dir}/pipe1.rb ONE",
                            "#{@ruby} #{@dir}/pipe1.rb TWO",
                            "#{@ruby} #{@dir}/pipe1.rb THREE" ]
    jobs = [ "1", "2", "3", "foo", "5", "6", "7" ].map { |v| WPop.new v } 

    assert_equal( 0, pipes.jobs_processed )   
    pipes.run jobs
    assert_equal( jobs.size, pipes.jobs_processed )  

    assert_equal( 7, jobs.size )
    worker = {}
    jobs.each do |j|
      assert_equal( 2,  j.parse.split(' ').size )
      assert_equal( j.phenotype, j.parse.split(' ').last )
      worker[ j.parse.split(' ').first ] = nil
    end
    assert_equal( ['ONE', 'THREE', 'TWO'], worker.keys.sort )

    jobs2 = [ "10", "20", "30", "forty", "05", "06", "07", "eighty" ].map { |v| WPop.new v } 

    pipes.run jobs2
    assert_equal( jobs.size+jobs2.size, pipes.jobs_processed ) 

    assert_equal( 8, jobs2.size )
    worker = {}
    jobs2.each do |j|
      assert_equal( 2,  j.parse.split(' ').size )
      assert_equal( j.phenotype, j.parse.split(' ').last )
      worker[ j.parse.split(' ').first ] = nil
    end
    assert_equal( ['ONE', 'THREE', 'TWO'], worker.keys.sort )

    cmds = [ "#{@ruby} #{@dir}/pipe1.rb first", "#{@ruby} #{@dir}/pipe1.rb second" ]
    pipes.commands = cmds

    jobs3 = [ "1", "2", "3", "foo", "5", "6", "7" ].map { |v| WPop.new v } 
   
    pipes.run jobs3
    assert_equal( jobs.size+jobs2.size+jobs3.size, pipes.jobs_processed )

    assert_equal( 7, jobs3.size )
    worker = {}
    jobs3.each do |j|
      assert_equal( 2,  j.parse.split(' ').size )
      assert_equal( j.phenotype, j.parse.split(' ').last )
      worker[ j.parse.split(' ').first ] = nil
    end
    assert_equal( ['first', 'second'], worker.keys.sort )

    #pipes.close
  end

  def test_empty_new
    pipes = WorkPipes.new
    assert_equal( [], pipes.commands )

    cmds = [ "#{@ruby} #{@dir}/pipe1.rb 1st", "#{@ruby} #{@dir}/pipe1.rb 2nd" ]
    pipes.commands = cmds
    assert_equal( cmds, pipes.commands )

    jobs = [ "10", "20", "30", "foo", "5", "6", "7" ].map { |v| WPop.new v }
    pipes.run jobs

    assert_equal( 7, jobs.size )
    worker = {}
    jobs.each do |j|
      assert_equal( 2,  j.parse.split(' ').size )
      assert_equal( j.phenotype, j.parse.split(' ').last )
      worker[ j.parse.split(' ').first ] = nil
    end
    assert_equal( ['1st', '2nd'], worker.keys.sort )
  end

  def test_target_source
    cmds = [ "#{@ruby} #{@dir}/pipe1.rb 1st", "#{@ruby} #{@dir}/pipe1.rb 2nd" ]
    pipes = WorkPipes.new( cmds, 'to=', :from )
    assert_equal( 'to=', pipes.destination )
    assert_equal( :from, pipes.source )

    jobs = [ "10", "20", "30", "foo", "5", "6", "7" ].map { |v| WPopFT.new v }
    
    pipes.run jobs

    worker = {}
    jobs.each do |j|
      assert_equal( 2,  j.to.split(' ').size )
      assert_equal( j.from, j.to.split(' ').last )
      worker[ j.to.split(' ').first ] = nil
    end
    assert_equal( ['1st', '2nd'], worker.keys.sort )

    pipes.destination = :to2=
    pipes.source = 'to'
    assert_equal( :to2=, pipes.destination )
    assert_equal( 'to', pipes.source )

    pipes.run jobs

    worker = {}
    jobs.each do |j|
      assert_equal( 3, j.to2.split(' ').size )
      assert_equal( j.from, j.to2.split(' ').last )
      worker[ j.to2.split(' ').first ] = nil
    end
    assert_equal( ['1st', '2nd'], worker.keys.sort )
  end

#  def test_stderr_pipe
#    pipes = WorkPipes.new [ "#{@ruby} #{@dir}/pipe1.rb 1st", "#{@ruby} #{@dir}/pipe_stderr.rb" ]
#    jobs = [ "1", "2", "3", "2", "3", "2", "3" ].map { |v| WPop.new v }
#    exception = assert_raise( RuntimeError ) { pipes.run jobs } 
#    assert_equal( "WorkPipes: pipe '#{@dir}/pipe_stderr.rb' wrote to stderr", exception.message )      
#  end

  def test_ending_pipe
    pipes = WorkPipes.new [ "#{@ruby} #{@dir}/pipe1.rb 1st", "#{@ruby} #{@dir}/pipe_ending.rb 2" ]
    jobs = [ "1", "2", "3", "2", "3", "2", "3" ].map { |v| WPop.new v }
    exception = assert_raise( RuntimeError ) { pipes.run jobs } 
    assert( /ended$/ =~ exception.message )      
  end

  def test_no_commands_provided
    pipes = WorkPipes.new   
    jobs = [ "1", "2", "3" ].map { |v| WPop.new v }   
    exception = assert_raise( RuntimeError ) { pipes.run jobs } 
    assert_equal( "WorkPipes: no pipes available", exception.message )   
  end

  def test_blocking_pipe
    pipes = WorkPipes.new [ "#{@ruby} #{@dir}/pipe1.rb 1st", "#{@ruby} #{@dir}/pipe_blocking.rb" ]

    assert_equal( 120, pipes.timeout )
    pipes.timeout = 2
    assert_equal( 2, pipes.timeout )

    jobs = [ "1", "2", "3", "2", "3", "2", "3" ].map { |v| WPop.new v }
    exception = assert_raise( RuntimeError ) { pipes.run jobs }
    if /win/ =~ RbConfig::CONFIG['host_os']
      assert( /ended$/ =~ exception.message )
    else
      assert_equal( "WorkPipes: watchdog barked", exception.message )
    end
  end

  def test_batch_marker
    pipes = WorkPipes.new
    pipes.timeout = 2

    cmds = [ "#{@ruby} #{@dir}/pipe_mark.rb 1st", "#{@ruby} #{@dir}/pipe_mark.rb 2nd" ]
    pipes.commands = cmds
    assert_equal( cmds, pipes.commands )

    jobs = [ "10", "20", "30", "foo", "5", "6", "7" ].map { |v| WPopBatch.new v }
    pipes.run jobs

    assert_equal( 7, jobs.size )
    worker = {}
    jobs.each do |j|
      out = j.parse.split(' ')
      assert_equal( 2,  out.size )
      assert_equal( j.phenotype, out.last )
      worker[ out.first ] = nil
    end
    assert_equal( ['1st', '2nd'], worker.keys.sort )
  end

  def test_batch_marker_more
    pipes = WorkPipes.new
    pipes.timeout = 2

    cmds = [ "#{@ruby} #{@dir}/pipe_mark.rb 1st",
             "#{@ruby} #{@dir}/pipe_mark.rb 2nd",
             "#{@ruby} #{@dir}/pipe_mark.rb 3rd" ]
    pipes.commands = cmds
    assert_equal( cmds, pipes.commands )

    tasks = []
    (1..(cmds.size*8+1)).each { |i| tasks << i.to_s }
    jobs = tasks.map { |v| WPopBatch.new v }

    pipes.run jobs

    worker = {}
    jobs.each do |j|
      out = j.parse.split(' ')
      assert_equal( 2,  out.size )
      assert_equal( j.phenotype, out.last )
      worker[ out.first ] = nil
    end
    assert_equal( ['1st', '2nd', '3rd'], worker.keys.sort )
  end
 
  def test_doubling
    pipes = WorkPipes.new [ "#{@ruby} #{@dir}/pipe_doubling.rb ONE", 
                            "#{@ruby} #{@dir}/pipe_doubling.rb TWO" ]
    jobs = [ "1", "DOUBLE_LINE", "3", "foo", "5", "6", "7" ].map { |v| WPop.new v } 
    exception = assert_raise( RuntimeError ) { pipes.run jobs } 
    assert_equal( "WorkPipes: mismatching inputs and outputs, check markers.", exception.message )   
  end

  def test_batch_mark_not_set_fix
    pipes = WorkPipes.new [ "#{@ruby} #{@dir}/pipe1.rb ONE",
                            "#{@ruby} #{@dir}/pipe1.rb TWO",
                            "#{@ruby} #{@dir}/pipe1.rb THREE" ]
    jobs = [ "1", "2", "3", "foo", "5", "6", "7" ].map { |v| WPopBatchNotSet.new v } 

    assert_equal( 0, pipes.jobs_processed )   
    pipes.run jobs
    assert_equal( jobs.size, pipes.jobs_processed )  

    assert_equal( 7, jobs.size )
    worker = {}
    jobs.each do |j|
      assert_equal( 2,  j.parse.split(' ').size )
      assert_equal( j.phenotype, j.parse.split(' ').last )
      worker[ j.parse.split(' ').first ] = nil
    end
    assert_equal( ['ONE', 'THREE', 'TWO'], worker.keys.sort )
  end
 
end


