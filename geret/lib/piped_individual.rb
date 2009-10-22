require 'lib/shorten'

module Util

  class PipedIndividual < Individual

    PipedIndSchema = Struct.new( 'PipedIndSchema', :symb, :conversion )

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
   
    def parse= row
      items = row.split( /\s+/ )
      raise "PipedIndividual: parse= expecting #{@@schema.size} items, got #{items.size}" unless @@schema.size == items.size

      items.each_with_index do |item,index|
        value = item.send( @@schema[index].conversion )
        send( "#{@@schema[index].symb}=", value )
      end
    end

    def PipedIndividual.pareto_core( klass, par )
      include klass     
      Pareto.clear_objectives PipedIndividual

      par.each do |item|
        item.each_pair do |sym,dir|
          attr_accessor sym unless method_defined? sym

          case dir.to_s
          when 'maximize'
            Pareto.maximize( PipedIndividual, sym )
          when 'minimize'
            Pareto.minimize( PipedIndividual, sym )
          else
            raise "PipedIndividual:wrong objective direction '#{dir}' for objective '#{sym}'" 
          end

        end
      end
    end

  end # class

end # module


