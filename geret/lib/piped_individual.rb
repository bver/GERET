require 'lib/shorten'

module Util

  class PipedIndividual < Individual

    PipedIndSchema = Struct.new( 'PipedIndSchema', :symb, :conversion )
    @@phenotype_mark = ''
    @@batch_mark = ''

    def initialize( mapper, genotype )
      super
      @phenotype += @@phenotype_mark unless @phenotype.nil?
    end

    def parse= row
      items = row.gsub(/^\s+/,'').gsub(/\s+$/,'').split( /\s+/ )
      raise "PipedIndividual: parse= expecting #{@@schema.size} items, got #{items.size}" unless @@schema.size == items.size

      items.each_with_index do |item,index|
        value = item.send( @@schema[index].conversion )
        send( "#{@@schema[index].symb}=", value )
      end
    end

    def batch_mark
      @@batch_mark
    end

    def stopping_condition
      @@thresh_values.each_pair do |symb,value|
        return false if @@thresh_over[symb] ? ( send(symb) <= value ) : ( send(symb) >= value )
      end

      true
    end
   
    def PipedIndividual.pipe_output outputs
      
      @@schema = []     

      outputs.each do |item|
        item.each_pair do |sym,conv|

          attr_accessor sym unless method_defined? sym

          @@schema << PipedIndSchema.new( sym, conv )
        end
      end

    end

    def PipedIndividual.pareto par
      PipedIndividual.pareto_core( Pareto, par )
    end

    def PipedIndividual.weak_pareto par
      PipedIndividual.pareto_core( WeakPareto, par )
    end

    def PipedIndividual.pareto_core( klass, par )
      include klass     
      Pareto.clear_objectives PipedIndividual
      @@thresh_over = {}

      par.each do |item|
        item.each_pair do |sym,dir|
          attr_accessor sym unless method_defined? sym

          case dir.to_s
          when 'maximize'
            Pareto.maximize( PipedIndividual, sym )
            @@thresh_over[ sym ] = true
          when 'minimize'
            Pareto.minimize( PipedIndividual, sym )
            @@thresh_over[ sym ] = false
          else
            raise "PipedIndividual:wrong objective direction '#{dir}' for objective '#{sym}'" 
          end

        end
      end
    end

    def PipedIndividual.mark_phenotype mark
      @@phenotype_mark = mark
    end

    def PipedIndividual.mark_batch mark
      @@batch_mark = mark
    end
    
    def PipedIndividual.thresholds thresh
      @@thresh_values = thresh
    end
    
  end # class

end # module


