
module PopulationArchiveSupport
  
  def prepare_archive_and_population
    @archive, @population = @store.load
    @archive = [] if @archive.nil?
    @population = [] if @population.nil?

    @report << "loaded #{@population.size} population individuals"   
    @report << "creating #{@population_size - @population.size} population individuals"
    init_population( @population, @population_size )
    @report << "loaded #{@archive.size} archive individuals"
  end

  def teardown
    @report << "--------- finished:"
    @store.save [@archive, @population]
    return @report   
  end
  
end

