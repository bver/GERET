
class Mutation
  def initialize
    @random = Kernel
  end

  attr_accessor :random

  def mutation orig
    mutant = orig.clone
    max = mutant.max

    where = @random.rand( orig.size )
    mutant[ where ] = @random.rand( max+1 )
    mutant
  end

end

