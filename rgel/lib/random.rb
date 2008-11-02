
class Random
  def initialize mode

    @core = proc {|max| Kernel::rand max }

    case mode

    when :stochastic
      srand

    when :repeatable
      srand 42

    when :deterministic
      @predef = nil
      @core = proc do |max|
        raise 'Random: set_predef() in :deterministic mode not called' if @predef.nil?
        raise 'Random: shortage of :deterministic values' if @predef.empty?

        max = 1.0 if max == 0
        raise 'Random: :deterministic value exceeded' if @predef.first > max 

        return @predef.shift
      end

    else
      raise 'Random: mode not supported'

    end
  end

  attr_reader :predef 

  def set_predef arg
    @predef = Array.new arg
  end

  def rand max=0
    @core.call(max)
  end
end

