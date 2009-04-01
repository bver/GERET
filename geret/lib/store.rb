
class Store
  def initialize filename
    @filename = filename 
  end

  attr_accessor :filename

  def save population
    File.open( @filename, "w" ) { |f| Marshal.dump(population, f) }
  end

  def load 
    population = []
    File.open( @filename ) { |f| population = Marshal.load f }
    population
  end
end


