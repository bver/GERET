
module Util

  class WorkPipes

    def initialize cmds #=nil
      @pipes = []
      self.commands = cmds #unless cmds.nil?
    end

    def active_commands
      nil #todo
    end

    def commands= cmds
      self.close
      @pipes = cmds.map { |cmd| IO.popen( cmd, 'r+' ) }
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
    end

  end

end

