
class RandomInit
  def initialize magnitude
    @random = Kernel
    if magnitude.kind_of? Array
      @magnitude = magnitude
    else
      @magnitude = [magnitude]
    end
  end

  attr_accessor :random, :magnitude

  def init length
    gen = []
    length.divmod(@magnitude.size).first.times do
      @magnitude.each {|m| gen.push @random.rand(m) }
    end
    gen
  end
end

