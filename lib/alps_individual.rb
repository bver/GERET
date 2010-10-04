
module Util

  # This class implements a necessary logic for ALPS strategy. See:
  # http://www.cs.york.ac.uk/rts/docs/GECCO_2006/docs/p815.pdf
  module AlpsIndividual

    # Set the AGE_GAP parameter of the ALPS. Required for AlpsIndividual.age_limits computation.
    # This is the multiplier of the age_limits serie.
    def AlpsIndividual.age_gap gap
      @@age_gap = gap
      @@limits = nil
    end

    # Set the aging scheme parameter. Required for AlpsIndividual.age_limits computation.   
    # Allowed values are: 
    #   :linear .. 1, 2, 3, 4, 5...
    #   :fibonacci .. 1, 2, 3, 5, 8, 13, 21...
    #   :polynomial .. 1, 2, 4, 9, 16, 25, 49...
    #   :exponential .. 1, 2, 4, 8, 16, 32, 64...
    #
    def AlpsIndividual.aging_scheme scheme
      @@aging_scheme = scheme
      @@limits = nil     
    end

    # Set the maximum number of layers (the requred length of the AlpsIndividual.age_limits serie).
    def AlpsIndividual.layers layers
      raise "AlpsIndividual: not enough layers, needed at least 2" if layers < 2
      @@layers = layers
      @@limits = nil     
    end

    # Get the age limit for each layer. The result is the AlpsIndividual.aging_scheme serie
    # of the AlpsIndividual.layers length, multiplied by AlpsIndividual.age_gap.
    def AlpsIndividual.age_limits
      return @@limits unless @@limits.nil?

      case @@aging_scheme 

        when :linear
          s = [ 1 ]
          s << s.last + 1 while s.size < @@layers 

        when :fibonacci
          s = [ 1, 2 ] # as defined in the original paper, there is a missing F1=1 member
          s << s.last + s[ s.size-2 ] while s.size < @@layers 

        when :polynomial
          s = []
          (1..@@layers).each { |i| s << i * i }

        when :exponential
          s = []
          (0...@@layers).each { |i| s << 2 ** i }

        else 
          raise "AlpsIndividual: a scheme '#{@@aging_scheme}' not supported"

      end

      return @@limits = s.map { |i| i * @@age_gap }
    end

    # The age of the individual. The newly created one has the age 0.
    # If the genome of the individual is based of the genome(s) of the parent(s), 
    # AlpsIndividual#parents method is to be used.
    #
    def age
      @age = 0 unless defined? @age
      @age
    end
    
    # Compute the AlpsIndividual#age of the individual from ages of it's parent(s).
    # If p1 and p2 are AlpsIndividual parents, the age will be:
    #   my.age = 1 + max( p1.age, p2.age )
    #
    def parents( p1, p2=nil )
      @age = 1 + ( ( p2.nil? or p1.age > p2.age ) ? p1.age : p2.age )
    end

    # Compute the index of the layer the individual belongs to.  
    # The result depends on AlpsIndividual.age_limits and AlpsIndividual#age.
    #
    def layer
      return nil unless defined? @@limits
      AlpsIndividual.age_limits.each_with_index do |max,i|
        return i if self.age <= max
      end
      return @@limits.size
    end

  end

end

