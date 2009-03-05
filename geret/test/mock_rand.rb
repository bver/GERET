
class MockRand

   def initialize array=[]
     @predef = array
   end

   def rand max=nil
     raise 'MockRand: set_predef() in :deterministic mode not called' if @predef.nil?
     raise 'MockRand: shortage of values' if @predef.empty?

     now = @predef.shift

     if now.kind_of? Hash
       ret = now.fetch(max,nil)
       raise "MockRand: unexpected argument (#{max}), expected (#{now.keys.join(', ')})" if ret.nil?  
       return ret
     else
       max = 1.0 if max == nil
       raise 'MockRand: value exceeded' if now > max 
       return now 
     end
    
   end

   attr_accessor :predef

end

