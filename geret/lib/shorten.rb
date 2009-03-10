
class Shorten
  def initialize
    @random = Kernel
    @stochastic = false
  end
  
  attr_accessor :random, :stochastic

  def shorten( gen, max )
    return gen.clone if gen.size <= max
    point = @stochastic ? (@random.rand( gen.size+1-max ) + max) : max
    gen.clone[0...point]
  end

end

