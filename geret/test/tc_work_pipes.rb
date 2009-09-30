#!/usr/bin/ruby

require 'test/unit'
require 'lib/work_pipes'

include Util

class TC_WorkPipes  < Test::Unit::TestCase
  
  def setup
    @dir = "#{File.dirname(__FILE__)}/data/"
  end

  def test_basic
    pipes = WorkPipes.new [ "#{@dir}/pipe1.rb ONE", 
                            "#{@dir}/pipe1.rb TWO", 
                            "#{@dir}/pipe1.rb THREE" ]
    jobs = [ "1", "2", "3", "foo", "5", "6", "7" ]
    result = pipes.run jobs

    assert_equal( 7, jobs.size )
    assert_equal( jobs.size, result.size )
    assert_equal( "ONE 1\n", result[0] )
    assert_equal( "TWO 2\n", result[1] )
    assert_equal( "THREE 3\n", result[2] )
    assert_equal( "ONE foo\n", result[3] )
    assert_equal( "TWO 5\n", result[4] )
    assert_equal( "THREE 6\n", result[5] )
    assert_equal( "ONE 7\n", result[6] )

    jobs2 = [ "10", "20", "30" ]
    result = pipes.run jobs2

    assert_equal( jobs2.size, result.size )
    assert_equal( "TWO 20\n", result[0] )
    assert_equal( "THREE 30\n", result[1] )
    assert_equal( "ONE 10\n", result[2] )

    cmds = [ "#{@dir}/pipe1.rb first", "#{@dir}/pipe1.rb second" ] 
    pipes.commands = cmds

    result = pipes.run jobs

    assert_equal( jobs.size, result.size )
    assert_equal( "first 1\n", result[0] )
    assert_equal( "second 2\n", result[1] )
    assert_equal( "first 3\n", result[2] )
    assert_equal( "second foo\n", result[3] )
    assert_equal( "first 5\n", result[4] )
    assert_equal( "second 6\n", result[5] )
    assert_equal( "first 7\n", result[6] )

    #pipes.close
  end

  def test_empty_new
    pipes = WorkPipes.new
    assert_equal( [], pipes.commands )

    cmds = [ "#{@dir}/pipe1.rb 1st", "#{@dir}/pipe1.rb 2nd" ] 
    pipes.commands = cmds
    assert_equal( cmds, pipes.commands )

    jobs = [ "10", "20", "30" ]
    result = pipes.run jobs

    assert_equal( jobs.size, result.size )
    assert_equal( "1st 10\n", result[0] )
    assert_equal( "2nd 20\n", result[1] )
    assert_equal( "1st 30\n", result[2] )
  end

  def test_failing_pipe
    #assert false
  end

  def test_ending_pipe
    #assert false
  end

  def test_no_more_pipes
    #assert false
  end

  def test_no_commands_provided
    #assert false
  end

  def test_blocking_pipe
    #assert false
  end

  def test_preparation_of_jobs
    #assert false
  end

end
