
class MockRand

   def initialize array=[]
     @predef = array
   end

   def rand max=0
     raise 'MockRand: shortage of values' if @predef.empty?

     now = @predef.shift

     if now.kind_of? Hash
       ret = now.fetch(max,nil)
       raise "MockRand: unexpected argument (#{max}), expected (#{now.keys.sort.join(', ')})" if ret.nil?  
       return ret
     else
       max = 1.0 if max == 0
       raise 'MockRand: value exceeded' if now > max 
       return now 
     end
    
   end

   attr_accessor :predef

end

