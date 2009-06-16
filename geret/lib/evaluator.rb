
# Simple Ruby Evaluator which uses Kernel.eval
class Evaluator
  def initialize
    @code = nil
  end

  # The code to be evaluated (a text with a Ruby syntax, may contain unitialised variables)
  attr_accessor :code

  # Evaluate the code. args is a hash containing named arguments:
  #   e = Evaluator.new
  #   e.code = "x + y"
  #   e.run {x=>1, y=>2} # returns 3
  #   e.run {x=>10, y=>20} # returns 30
  #   
  # If there is an exception thrown during evaluation, nil is returned.
  # 
  def run args
    raise "Evaluator: no code supplied" if @code.nil?
    arguments = ''
    args.each_pair { |key,value| arguments += "#{key} = #{value.inspect};" }
    begin
      eval arguments + @code
    rescue
      nil
    end
  end

end

