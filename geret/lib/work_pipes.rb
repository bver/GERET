
module Util

  class WorkPipes

    def initialize cmds=nil
      @pipes = []
      @commands = {}
      self.commands = cmds unless cmds.nil?
    end

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
      while index < jobs.size or assigned.values.detect { |t| !t.empty? }

        ready = select( @pipes, @pipes, nil, 0 )
        next if ready.nil?

        # read end
        ready.first.each do |pipe|
          output = pipe.gets
          if output.nil?
            #raise "WorkPipes: lost assignments?" unless assigned[pipe].empty?
            pipe.close
            @pipes.delete pipe
            next
          end
          jobs[ assigned[pipe].shift ].fitness = output
        end

        # write end
        ready[1].each do |pipe|
          break if index >= jobs.size         
          input = jobs[index].phenotype
          tasks = assigned.fetch( pipe, [] )
          tasks.push index
          assigned[pipe] = tasks
          pipe.puts input
          index += 1
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

