
class RandomInit
  def initialize magnitude
    @random = Kernel
    @magnitude = magnitude
  end

  attr_accessor :random, :magnitude

  def init length
    gen = []
    length.times { gen.push @random.rand(@magnitude) }
    gen
  end
end

