#!/usr/bin/ruby

require 'test/unit'
require 'lib/work_pipes'

include Util

WPop = Struct.new( 'WPop', :phenotype, :fitness )
WPopFT = Struct.new( 'WPopFT', :from, :to, :to2 )

class TC_WorkPipes  < Test::Unit::TestCase
 
  def setup
    @dir = "#{File.dirname(__FILE__)}/data/"
  end

  def test_basic
    pipes = WorkPipes.new [ "#{@dir}/pipe1.rb ONE", 
                            "#{@dir}/pipe1.rb TWO", 
                            "#{@dir}/pipe1.rb THREE" ]
    jobs = [ "1", "2", "3", "foo", "5", "6", "7" ].map { |v| WPop.new v } 

    pipes.run jobs

    assert_equal( 7, jobs.size )
    worker = {}
    jobs.each do |j|
      assert_equal( 2,  j.fitness.split(' ').size )
      assert_equal( j.phenotype, j.fitness.split(' ').last )
      worker[ j.fitness.split(' ').first ] = nil
    end
    assert_equal( ['ONE', 'THREE', 'TWO'], worker.keys.sort )

    jobs2 = [ "10", "20", "30", "forty", "05", "06", "07", "eighty" ].map { |v| WPop.new v } 

    pipes.run jobs2

    assert_equal( 8, jobs2.size )
    worker = {}
    jobs.each do |j|
      assert_equal( 2,  j.fitness.split(' ').size )
      assert_equal( j.phenotype, j.fitness.split(' ').last )
      worker[ j.fitness.split(' ').first ] = nil
    end
    assert_equal( ['ONE', 'THREE', 'TWO'], worker.keys.sort )

    cmds = [ "#{@dir}/pipe1.rb first", "#{@dir}/pipe1.rb second" ] 
    pipes.commands = cmds

    jobs = [ "1", "2", "3", "foo", "5", "6", "7" ].map { |v| WPop.new v } 
   
    result = pipes.run jobs

    assert_equal( 7, jobs.size )
    worker = {}
    jobs.each do |j|
      assert_equal( 2,  j.fitness.split(' ').size )
      assert_equal( j.phenotype, j.fitness.split(' ').last )
      worker[ j.fitness.split(' ').first ] = nil
    end
    assert_equal( ['first', 'second'], worker.keys.sort )

    #pipes.close
  end

  def test_empty_new
    pipes = WorkPipes.new
    assert_equal( [], pipes.commands )

    cmds = [ "#{@dir}/pipe1.rb 1st", "#{@dir}/pipe1.rb 2nd" ] 
    pipes.commands = cmds
    assert_equal( cmds, pipes.commands )

    jobs = [ "10", "20", "30", "foo", "5", "6", "7" ].map { |v| WPop.new v }
    pipes.run jobs

    assert_equal( 7, jobs.size )
    worker = {}
    jobs.each do |j|
      assert_equal( 2,  j.fitness.split(' ').size )
      assert_equal( j.phenotype, j.fitness.split(' ').last )
      worker[ j.fitness.split(' ').first ] = nil
    end
    assert_equal( ['1st', '2nd'], worker.keys.sort )
  end

  def test_target_source
    cmds = [ "#{@dir}/pipe1.rb 1st", "#{@dir}/pipe1.rb 2nd" ] 
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
#    pipes = WorkPipes.new [ "#{@dir}/pipe1.rb 1st", "#{@dir}/pipe_stderr.rb" ]
#    jobs = [ "1", "2", "3", "2", "3", "2", "3" ].map { |v| WPop.new v }
#    exception = assert_raise( RuntimeError ) { pipes.run jobs } 
#    assert_equal( "WorkPipes: pipe '#{@dir}/pipe_stderr.rb' wrote to stderr", exception.message )      
#  end

  def test_ending_pipe
    pipes = WorkPipes.new [ "#{@dir}/pipe1.rb 1st", "#{@dir}/pipe_ending.rb 2" ]
    jobs = [ "1", "2", "3", "2", "3", "2", "3" ].map { |v| WPop.new v }
    exception = assert_raise( RuntimeError ) { pipes.run jobs } 
    assert_equal( "WorkPipes: pipe '#{@dir}/pipe_ending.rb 2' ended", exception.message )      
  end

  def test_no_commands_provided
    pipes = WorkPipes.new   
    jobs = [ "1", "2", "3" ].map { |v| WPop.new v }   
    exception = assert_raise( RuntimeError ) { pipes.run jobs } 
    assert_equal( "WorkPipes: no pipes available", exception.message )   
  end

  def test_blocking_pipe
    pipes = WorkPipes.new [ "#{@dir}/pipe1.rb 1st", "#{@dir}/pipe_blocking.rb" ]
    jobs = [ "1", "2", "3", "2", "3", "2", "3" ].map { |v| WPop.new v }
    exception = assert_raise( RuntimeError ) { pipes.run jobs } 
    assert_equal( "WorkPipes: watchdog barked", exception.message )      
  end

  def test_lost_assignments_xpt
  end
end
