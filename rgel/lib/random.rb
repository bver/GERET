
# Random class is basically a wrapper over Kernel::rand() function, supporting
# also a special :deterministic mode, which is helpful for unit testing.
#
class Random

  # creates a new random generator
  # - mode can be :stochastic, :repeatable or :deterministic
  #
  # :stochastic - classic production mode, generating random numbers as Kernel::rand does
  #
  # :repeatable - same as :stochastic but producing same sequences, initialized by Kernel::srand(42)
  #
  # :deterministic - producing predefined sequences, user needs to call set_predef() first
  #
  def initialize mode

    @core = proc {|max| Kernel::rand max }
    @mode = mode

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

  # gets the remaining sequence for rand() calls (useful only in :deterministic mode)
  attr_reader :predef

  # gets the mode of the random generator instance
  attr_reader :mode

  # when in :deterministic mode, this method assigns the predefined sequence to the generator.
  #
  # - arg is the sequence (array) of numbers for rand() calls
  #
  # arg.first will be the result subsequent rand() call, arg[1] will be the second one, etc.
  #
  def set_predef arg
    raise 'Random: calling set_predef in wrong mode' if @mode != :deterministic
    @predef = Array.new arg
  end

  # when in :stochastic or :repeatable mode, it is same as Kernel::rand(); 
  # see http://www.rubycentral.com/book/ref_m_kernel.html#Kernel.rand 
  #
  # when in :deterministic mode, it follows the predefined sequence.
  #
  def rand max=0
    @core.call(max)
  end
end

