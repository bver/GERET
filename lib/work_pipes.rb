
require 'rbconfig'

module Util

  # This class separates GERET engine from the domain-specific scripts.
  # WorkPipes manages the set of external pipes connecting the pool of GE individuals with independent worker scripts.
  # The worker script reads the phenotype (typically the source of the program in the specific language) from 
  # the standard input, evaluates it and writes the objective value(s) (typically fitness, error or another metrics)
  # to the standard output.
  # The worker script can set up the evaluating environment, wait for the program source in the loop, run the compiler 
  # when the source is available, run the compiled program to evaluate it, collect the results and pass it to back 
  # through the standard output to the caller, wait for another source, etc.
  #
  # Running more than one worker script processes in parallel is possible and it brings the performance gain in parallel 
  # (or distributed) systems. The assignment of the specific work to the specific script cannot be directly controlled.
  #
  # The STDIN-STDOUT "protocol" is to be designed between the worker script and the domain-specific classes in the GERET.
  # For instance the Util::Individual can be subclassed using the domain-specific grammar, producing the source texts 
  # recognizable by the worker script. The grammar produces the "END-OF-PROGRAM" marker syntax which is parsed by the 
  # worker scxript; the syntax of objective values generated by the worker script is parsed by the Util::Individual's
  # subclass, etc.
  #
  # Flushing the STDOUT (by $stdout.flush or the analogous command in script's language) in the worker script is highly 
  # recommended because the WorkPipes waits for the script's output only for the certain time. This timeout can be set up 
  # to the sufficient value.
  #
  # The script should not terminate itself, the caller terminates it at the end of the process. The termination
  # of the worker script is considered as the error and raises the exception in the WorkPipes object.
  #
  class WorkPipes

    # Set up the worker script by the commands in cmds, use the dest and src for specifying attributes.
    # See WorkPipes#commands=, WorkPipes#destination and WorkPipes#source for details.
    def initialize cmds=nil, dest='parse=', src='phenotype'
      @pipes = []
      @commands = {}
      @destination = dest
      @source = src
      @timeout = 120
      self.commands = cmds unless cmds.nil?
    end

    # The method name for storing the worker script's output into the jobs object.
    # WorkPipes#run uses object.send( @destination, output ) The default is 'parse='. 
    attr_accessor :destination

    # The method for retrieving worker script's input from the jobs object.
    # WorkPipes#run uses input = object.send( @source ) The default is 'phenotype'. 
    attr_accessor :source

    # The time (in seconds) for which the WorkPipes waits for the worker scripts.
    # If there is no worker action (reading stdin or writing to stdout) detected 
    # for a given time, the exception is raised.
    attr_accessor :timeout

    # Command lines of the worker scripts.
    def commands
      @pipes.map { |pipe| @commands[pipe] }
    end

    # Run worker scripts using the cmds. The argument cmds is the Enumerable collection of the command lines.
    # Each script is run in the separate process by IO.popen.
    def commands= cmds
      self.close
      cmds.each do |cmd| 
        p = IO.popen( cmd, 'r+' )
        #p.sync = true
        @pipes << p 
        @commands[ p ] = cmd
      end
    end

    # Assing the work to the worker scripts and wait for results.
    # The jobs argument have to be the Enumerable collection of the work objects, typically the Array of 
    # Util::Individual subclasses. The work object has to provide the input (eg. the 'phenotype' attribute) 
    # for the work script using WorkPipes#source and has to be able to store the work script's output 
    # using the WorkPipes#destination method (eg. the 'PipedIndividual#parse=' method).
    # The WorkPipes#run can be called more times (eg. once per population's generation).
    def run jobs
      if /win/ =~ Config::CONFIG['host_os']
        run_select_broken jobs # IO.select is broken on windows
      else
        run_select_works jobs
      end
    end

    # Terminate all worker scripts.
    def close
      @pipes.each { |pipe| pipe.close }
      @pipes = []
      @commands = {}
    end

    protected

    def run_select_broken jobs
      raise "WorkPipes: no pipes available" if @pipes.empty?

      jobs.each_with_index do |job,index|
        # feed
        pind = index.divmod( @pipes.size ).last
        pipe = @pipes[pind]

        input = job.send( @source )
        pipe.puts input
      end

      if jobs.first.class.respond_to? :batch_mark
        marker = jobs.first.class.batch_mark
        @pipes.each { |pipe| pipe.puts marker }
      end
      
      jobs.each_with_index do |job,index|
        # harvest
        pind = index.divmod( @pipes.size ).last
        pipe = @pipes[pind]

        output = pipe.gets
        raise "WorkPipes: pipe '#{@commands[pipe]}' ended" if output.nil?
        job.send( @destination, output )
      end
    end

    def run_select_works jobs
      return if jobs.empty?

      batch = []
      if jobs.first.class.respond_to? :batch_mark
        marker = jobs.first.class.batch_mark
        batch = @pipes.clone
      end

      assigned = {}
      index = 0
      restart_watchdog
      while index < jobs.size or assigned.values.detect { |t| !t.empty? }
        raise "WorkPipes: watchdog barked" if watchdog_barking?

        raise "WorkPipes: no pipes available" if @pipes.empty?

        ready = select( @pipes, @pipes, nil, 0 )
        next if ready.nil?

        # error end - does not work, Open3.popen3 either
        #raise "WorkPipes: pipe '#{@commands[ready.last.first]}' wrote to stderr'" unless ready.last.empty?
       
        # read end
        ready.first.each do |pipe|
          output = pipe.gets
          raise "WorkPipes: pipe '#{@commands[pipe]}' ended" if output.nil?
          jobs[ assigned[pipe].shift ].send( @destination, output )
          restart_watchdog         
        end

        # write end
        ready[1].each do |pipe|
          
          if index >= jobs.size 
            if batch.include? pipe
              batch.delete pipe
              pipe.puts marker
            end
            next 
          end

          input = jobs[index].send( @source )
          tasks = assigned.fetch( pipe, [] )
          tasks.push index
          assigned[pipe] = tasks
          pipe.puts input
          index += 1
          restart_watchdog        
        end

      end
    end

    def restart_watchdog
      @watchdog = Time.now.tv_sec     
    end

    def watchdog_barking?
      Time.now.tv_sec - @watchdog >= @timeout 
    end

  end

end
