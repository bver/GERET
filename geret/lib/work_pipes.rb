
module Util

  class WorkPipes

    def initialize cmds=nil, dest='fitness=', src='phenotype'
      @pipes = []
      @commands = {}
      @destination = dest
      @source = src
      self.commands = cmds unless cmds.nil?
    end

    attr_accessor :destination
    attr_accessor :source

    def commands
      @pipes.map { |pipe| @commands[pipe] }
    end

    def commands= cmds
      self.close
      cmds.each do |cmd| 
        p = IO.popen( cmd, 'r+' )
        @pipes << p 
        @commands[ p ] = cmd
      end
    end

    def run jobs 

      assigned = {}
      index = 0
      watchdog = 100000
      while index < jobs.size or assigned.values.detect { |t| !t.empty? }
        watchdog -= 1
        raise "WorkPipes: watchdog barked" if watchdog <= 0

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
          watchdog = 100000         
        end

        # write end
        ready[1].each do |pipe|
          break if index >= jobs.size         
          input = jobs[index].send( @source )
          tasks = assigned.fetch( pipe, [] )
          tasks.push index
          assigned[pipe] = tasks
          pipe.puts input
          index += 1
          watchdog = 100000         
        end

      end
    end

    def close
      @pipes.each { |pipe| pipe.close }
      @pipes = []
      @commands = {}
    end

  end

end

