
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

    def run data
      result = []
      jobs = data.clone

      until data.size == result.size

        ready = select( @pipes, @pipes, nil, 0 )
        next if ready.nil?

        ready.first.each do |pipe|
          out = pipe.gets
          if out.nil?
            pipe.close
            @pipes.delete pipe
            next
          end
          result << out
        end

        ready[1].each { |pipe| pipe.puts jobs.shift unless jobs.empty? }

      end

      result
    end

    def close
      @pipes.each { |pipe| pipe.close }
      @pipes = []
      @commands = {}
    end

  end

end

