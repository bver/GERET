
require 'lib/individual'
require 'lib/pareto'

module Util

  # This is the universally configurable subclass of the Individual class, for the use with the WorkPipes evaluator.
  # The user can specify multiple objectives and the kind of their optimisation, describe the item names and types 
  # of the evaluator's output, define the stopping condition, etc.
  # All the configuration is done via ConfigYaml class using the yaml file, without the need of writing domain-specific
  # class for each task. 
  #
  class PipedIndividual < Individual

    PipedIndSchema = Struct.new( 'PipedIndSchema', :symb, :conversion )
    @@phenotype_mark = ''
    @@batch_mark = ''

    # Create the new phenotype, based on the genotype, using the mapper.
    def initialize( mapper, genotype )
      super
      @phenotype += @@phenotype_mark unless @phenotype.nil?
    end

    # Take the result of the phenotype evaluation and process it. The text row argument consists of one or more values, 
    # separated by the space. Meaning of these values and their type conversions must be specified by the
    # PipedIndividual.pipe_output static method, before calling parse=.
    #
    # For example:
    #   individual.row = '1243.32 42'  # suppose the pipe returns 2 values per one individual's evaluation
    #
    def parse= row
      items = row.gsub(/^\s+/,'').gsub(/\s+$/,'').split( /\s+/ )
      raise "PipedIndividual: parse= expecting #{@@schema.size} items, got #{items.size}" unless @@schema.size == items.size

      items.each_with_index do |item,index|
        value = item.send( @@schema[index].conversion )
        send( "#{@@schema[index].symb}=", value )
      end
    end

    # Return the text separating the batch of pipe inputs for one WorkPipes#run call. This text is set by the
    # PipedIndividual.mark_batch static method.
    def batch_mark
      @@batch_mark
    end

    # This method tests the individual for the meeting of stopping condition. If all conditions are met (ie. 
    # in the case of the 'winner' individual), the stopping_condition returns true.
    # Conditions have to be set by the PipedIndividual.thresholds static method.
    def stopping_condition
      @@thresh_values.each_pair do |symb,value|
        max = @@thresh_over.fetch( symb, nil )

        raise "PipedIndividual: optimisation direction not known for the objective '#{symb}'" if max.nil?
        return false if max ? ( send(symb) <= value ) : ( send(symb) >= value )
      end

      true
    end
   
    # Specify the schema for the parse= method (see). The outputs argument is to be the array of hashes describing 
    # each item of the pipe output, in the correct order. Each hash contains only one key-value pair. The hash key 
    # represents the name (symbol) of the attribute (usually the objective), the value is the conversion method for
    # parsing the text to the correct numeric type.
    # 
    # For example:
    #   schema = []
    #   schema << {:amount => 'to_f'}
    #   schema << {:score => 'to_i'}
    #   PipedIndividual.pipe_output schema
    #
    #   individual.row = '1243.32 42'  # suppose the pipe returns 2 values per one individual's evaluation
    #   individual.amount  # >> 1243.32
    #   individual.score   # >> 42
    #
    def PipedIndividual.pipe_output outputs
      
      @@schema = []     

      outputs.each do |item|
        item.each_pair do |sym,conv|

          attr_accessor sym unless method_defined? sym

          @@schema << PipedIndSchema.new( sym, conv )
        end
      end

    end

    # Shorthand for the PipedIndividual.pareto_core( Moea::Pareto, par )
    def PipedIndividual.pareto par
      PipedIndividual.pareto_core( Moea::Pareto, par )
    end

    # Shorthand for the PipedIndividual.pareto_core( Moea::WeakPareto, par )
    def PipedIndividual.weak_pareto par
      PipedIndividual.pareto_core( Moea::WeakPareto, par )
    end

    # Describe the optimisation objectives for the Pareto module (see).
    # The outputs argument is to be the array of hashes describing each objective, in the correct order. 
    # Each hash contains only one key-value pair. The hash key represents the name (symbol) of the objective, 
    # the value is the 'direction' of the optimisation, ie. either 'minimize' or 'maximize'
    # The klass is either Moea::Pareto or Moea::WeakPareto, specifying the strong or weak pareto definition.
    #
    #   objectives = []
    #   objectives << {:amount => 'minimize'}
    #   objectives << {:score => 'maximize'}
    #   PipedIndividual.pareto objectives
    # 
    def PipedIndividual.pareto_core( klass, par )
      include klass     
      Moea::Pareto.clear_objectives PipedIndividual
      @@thresh_over = {}

      par.each do |item|
        item.each_pair do |sym,dir|
          attr_accessor sym unless method_defined? sym

          case dir.to_s
          when 'maximize'
            Moea::Pareto.maximize( PipedIndividual, sym )
            @@thresh_over[ sym ] = true
          when 'minimize'
            Moea::Pareto.minimize( PipedIndividual, sym )
            @@thresh_over[ sym ] = false
          else
            raise "PipedIndividual:wrong objective direction '#{dir}' for objective '#{sym}'" 
          end

        end
      end
    end

    # Set the optional text separating each phenotype in the pipe's input, if needed by the pipe process. 
    # This text is attached to the end of :phenotype attribute, defaulting to ''.
    def PipedIndividual.mark_phenotype mark
      @@phenotype_mark = mark
    end

    # Set the optional text separating each WorkPipes#run call in the pipe's input, if needed by the pipe process. 
    # This text is retrieved by the WorkPipes's instance using PipedIndividual#batch_mark method, defaulting to ''.
    def PipedIndividual.mark_batch mark
      @@batch_mark = mark
    end
    
    # Specify the components of the stopping_condition method (see). The thresh argument is the hash describing 
    # each attribute of the stopping expression. The hash key represents the name (symbol) of the objective, 
    # the value is the threshold value used for comparision.
    # Note the 'direction' of the optimisation has to be set by the PipedIndividual.pareto_core static method. 
    # 
    # For example:
    #   objectives = []
    #   objectives << {:amount => 'minimize'}
    #   objectives << {:score => 'maximize'}
    #   PipedIndividual.pareto objectives
    # 
    #   condition = {}
    #   condition[ :amount ] = 5435.34
    #   condition[ :score ] = 61
    #   PipedIndividual.thresholds condition
    #   
    #   individual.amount = 8430.2
    #   individual.score = 144
    #   individual.stopping_condition # >> false (individual.amount <= 5435.34 and individual.score > 61)
    #
    def PipedIndividual.thresholds thresh
      @@thresh_values = thresh
    end
    
  end # class

end # module


