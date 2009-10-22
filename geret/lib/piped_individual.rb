require 'lib/shorten'

module Util

  class PipedIndividual < Individual

    PipedIndSchema = Struct.new( 'PipedIndSchema', :symb, :conversion )
    @@schema = []

    def PipedIndividual.pipe_output outputs
      outputs.each do |item|
        item.each_pair do |sym,conv|

          attr_accessor sym unless method_defined? sym

          @@schema << PipedIndSchema.new( sym, conv )
        end
      end
    end

    def PipedIndividual.pareto par
      include Pareto     
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

    def parse= row
      row.split(/\s+/).each_with_index do |item,index|
        value = item.send( @@schema[index].conversion )
        send( "#{@@schema[index].symb}=", value )
      end
    end

  end

end


