
class Store
  def initialize filename
    @filename = filename 
  end

  attr_accessor :filename

  def save population
    File.open( @filename, "w" ) { |f| Marshal.dump(population, f) }
  end

  def load 
    File.open( @filename ) { |f| return Marshal.load f }
  end
end


