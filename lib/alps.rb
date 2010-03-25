
module Util

  module Alps

    def Alps.age_gap gap
      @@age_gap = gap
    end

    def Alps.aging_scheme scheme
      @@aging_scheme = scheme
    end

    def Alps.layers layers
      @@layers = layers
    end

    def Alps.max_ages

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
          raise "Alps: a scheme '#{@@aging_scheme}' not supported"

      end

      return s.map { |i| i * @@age_gap }
    end


    def age
      @age = 0 unless defined? @age
      @age
    end
    
    def parents( p1, p2=nil )
      @age = 1 + ( ( p2.nil? or p1.age > p2.age ) ? p1.age : p2.age )
    end

  end

end

