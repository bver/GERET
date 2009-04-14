
class Store
  def initialize filename=nil
    @filename = filename 
  end

  attr_accessor :filename

  def save population
    File.open( @filename, "w" ) { |f| Marshal.dump(population, f) }
  end

  def load 
    return nil unless FileTest.readable? @filename
    File.open( @filename ) { |f| return Marshal.load(f)  }
  end
end


