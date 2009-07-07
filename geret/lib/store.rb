
# Population marshalling. Store class saves or loads the content of the population.
#
class Store

  # Set the path to the file.
  def initialize filename=nil
    @filename = filename 
  end

  # The path to the store file. 
  attr_accessor :filename

  # Save the population using Marshal.dump
  def save population
    File.open( @filename, "w" ) { |f| Marshal.dump(population, f) }
  end

  # Load the population using Marshal.load
  def load 
    return nil unless FileTest.readable? @filename
    File.open( @filename ) { |f| return Marshal.load(f)  }
  end

end


