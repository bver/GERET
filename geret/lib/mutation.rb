
class Mutation

  def initialize magnitude=nil
    @random = Kernel
    @magnitude = magnitude
  end

  attr_accessor :random, :magnitude

  def mutation orig
    mutant = orig.clone
    max = @magnitude.nil? ? mutant.max+1 : @magnitude
    where = @random.rand( orig.size )
    mutant[ where ] = @random.rand( max )
    mutant
  end

end

