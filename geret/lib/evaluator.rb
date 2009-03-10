
class Evaluator
  def initialize
    @code = nil
  end

  attr_accessor :code

  def run args
    raise "Evaluator: no code supplied" if @code.nil?
    arguments = ''
    args.each_pair { |key,value| arguments += "#{key} = #{value.inspect};" }
    eval arguments + @code
  end
end

