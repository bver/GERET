
require 'set'
require 'algorithm/support/algorithm_base'


class Deme
  attr_accessor :current, :pending, :level
  attr_reader :parent, :name

  def Deme.set_algo algo
    @@algo = algo
  end

  @@left_right = 0
  def initialize( parent=nil )
    @parent = parent
    @name = parent.nil? ? 'R' : "#{parent.name}#{@@left_right=1-@@left_right}"       
    restart
    @@algo.report << "#{@name}.initialize"
  end

  def restart
    unless !defined?(@current) or @current.empty? or @parent.nil?
      @current.slice( 0 ... @@algo.elite_size ).each do |individual|
        copy = individual.clone
        copy.parents individual   # increment age
        @parent.pending << copy
      end

      @@algo.report << "#{@name}.restart saved elite to #{@parent.name}.pending"
    end

    @current = @@algo.sort_spea2( @@algo.init_deme )
    @pending = []
    @level = 0
    @@algo.report << "#{@name}.restart @current.size=#{@current.size}"   
  end

  def breed( withparent=true )
    parents = @current.clone
    parents.concat @parent.current if withparent and not @parent.nil?
    
    parent_inc = 0
    @@algo.breed( parents ).each do |offspring|
      if offspring.layer == @level 
        @pending << offspring
      else
        abort "#{@name} losing individuals" if @parent.nil?      
        @parent.pending << offspring
        parent_inc += 1
      end
    end
    @@algo.report << "#{@name}.breed up=#{@parent.nil? ? '': @parent.name} withparent=#{withparent} parents.size=#{parents.size} self.pending.size=#{@pending.size} @parent.pending.size_inc=#{parent_inc}"      
  end
    
  def pde_elitism_eval_trunc

    uniq = Set.new
    elite = []

    copy_size = @@algo.deme_size - @pending.size
    copy_size = @@algo.elite_size if copy_size < @@algo.elite_size

    @current.slice( 0 ... copy_size ).each do |individual|
      copy = individual.clone
      copy.parents individual   # increment age
      elite << copy
      uniq << copy.phenotype unless uniq.include? copy.phenotype 
    end

    offspring = []
    @pending.each do |i| 
      next if uniq.include? i.phenotype 
      offspring << i
      uniq << i.phenotype
    end

    @current = @@algo.sort_spea2( elite + offspring ).slice( 0 ... @@algo.deme_size ) #trunc

    @@algo.report << "#{@name}.pde_elitism_eval @pending.size=#{@pending.size} -> offspring.size=#{offspring.size} + copy_size=#{copy_size} = @current.size=#{elite.size + offspring.size} -> #{@current.size}"        

    @pending = []   
  
  end

end

class AgeHierarchyTree < AlgorithmBase
  attr_accessor :max_layers, :elite_size, :aging_scheme, :age_gap, :layer_diagnostic, :deme_size, :report
  attr_reader :dominance

  def setup config
    super
     
    AlpsIndividual.age_gap @age_gap
    AlpsIndividual.aging_scheme @aging_scheme
    AlpsIndividual.layers @max_layers
    @report['age_limits'] << AlpsIndividual.age_limits.inspect

    Deme.set_algo self

    @dominance = Dominance.new
    @population = []
    @parents_stats = []

    @layers = [[ Deme.new ]]

    @report.next    
    return @report    
  end

  def step
    @report << "--------- step #{@steps}"
    
    if AlpsIndividual.age_limits.include? @steps

        @report << "--------- opening a new layer by unshift"       

        @layers.flatten.each { |deme| deme.level += 1 }
        new_layer = []
        @layers.first.each do |parent|
           new_layer << Deme.new(parent)
           new_layer << Deme.new(parent)
        end
        @layers.unshift new_layer

    elsif @steps>0
       
        reminder = @steps.divmod(@age_gap).last
        @layers.first.each_with_index do |deme,index|
           next unless reminder == index.divmod(@age_gap).last
           @report << "--------- restarting a deme #{deme.name}, index=#{index}"
           deme.restart
        end

    end

    # reporting
    @population = []
    @layers.flatten.each { |deme| @population.concat deme.current }
    @report.report @population
   
    # breeding
    if @layers.size > 1
      @layers.first.each  { |deme| deme.breed false }    
      @layers.flatten.each { |deme| deme.breed unless deme.parent.nil? }
    else
      @layers.first.first.breed
    end

    # pde, copying...
    @layers.flatten.each { |deme| deme.pde_elitism_eval_trunc }   

    # layer diagnostic
    @report['deme_sizes'] << (@layers.flatten.map { |layer| layer.current.size }).inspect
    @layers.flatten.each_with_index do |deme,index| 
      current = deme.current     
      current.first.objective_symbols.each do |objective|     
        values = current.map { |individual| individual.send(objective) }   
        min, max, avg, n = Util.statistics values  
        @report["deme_#{deme.name}_#{objective}"] << "min: #{min} max: #{max} avg: #{avg} n: #{n}"
      end
    end if @layer_diagnostic

    @report['numof_evaluations'] << @evaluator.jobs_processed if defined? @evaluator   
    @report['individuals_generated'] << @mapper.mapped_count
    
    @steps += 1   
    @report.next 
    return @report    
  end

  def init_deme
    init_population( [], @deme_size ) 
  end

  def breed( unsorted ) 

    layer = sort_spea2 unsorted

    # xover, mutations
    children = []   
    while children.size + @elite_size  < @deme_size
     
      parent1 = tournament(layer)

      if rand < @probabilities['crossover']

        parent2 = tournament(layer)

        child1, child2 = @crossover.crossover( 
                              parent1.genotype, parent2.genotype, 
                              parent1.track_support, parent2.track_support ) 

        individual = @cfg.factory( 'individual', @mapper, child1 ) 
        individual.parents( parent1, parent2 )
        @invalid_individuals += 1 unless individual.valid?       
        children << individual if individual.valid? 
       

        individual = @cfg.factory( 'individual', @mapper, child2 ) 
        individual.parents( parent1, parent2 )  
        @invalid_individuals += 1 unless individual.valid?       
        children << individual if individual.valid?

      end

      if rand < @probabilities['mutation']

        child = @mutation.mutation( parent1.genotype, parent1.track_support )
  
        individual = @cfg.factory( 'individual', @mapper, child ) 
        individual.parents( parent1 )       
        @invalid_individuals += 1 unless individual.valid?       
        children << individual if individual.valid?
        
      end

    end
  
    @evaluator.run children if defined? @evaluator
    children
  end 
  
  def sort_spea2 unsorted
    # sort each layer by pareto strength        
    layer = @dominance.rank_count( unsorted ).sort {|a,b| a.spea <=> b.spea }
      
    # extract individuals from dominance's shell     
    layer.map! { |fields| fields.original } 

    layer
  end

  protected
 
  def tournament layer 
    # works only on sorted data
    i1 = rand(layer.size)
    i2 = rand(layer.size)         
    layer[ i1 < i2 ? i1 : i2 ]
  end
 
end



