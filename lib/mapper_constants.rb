
module Mapper


  #
  # embedded_constants:
  #    const1:
  #      codons: 1
  #      type: Float
  #      min: -2.0
  #      max: 2.0
  #    C2:
  #      codons: 2
  #      type: Integer
  #      min: 0
  #      max: 80000
  #
  module ConstantsInGenotype

    class EmbeddedConstantData 
      attr  :type, :codons, :min, :step

      def initialize( type, codons, min, step )
         @type = type
         @codons = codons
         @min = min
         @step = step
      end

      def mapping index
         value = @min + @step * index
         (@type == Integer) ? value.round : value
      end
    end

    attr_reader :embedded
    
    def embedded_constants= config
      @embedded = {}
      config.each_pair do |name,params|
        raise "ConstantsInGenotype: missing min for constant '#{name}'" unless params.has_key? 'min'
        min = params['min']
        
        raise "ConstantsInGenotype: missing max for constant '#{name}'" unless params.has_key? 'max'       
        max = params['max']

        codons = params.has_key?('codons') ? params['codons'] : 1

        type = (min.integer? and max.integer?) ? Integer : Float
        size = 2 ** (@codon.bit_size * codons)
        step = (max - min).to_f / (size-1)
        @embedded[name] = EmbeddedConstantData.new( type, codons, min, step )
      end
    end

    def modify_expansion_base( exp, genome )
      return unless defined? @embedded
      exp.each do |token|
        next unless token.type == :literal 
        found = @embedded.fetch( token.data, nil )
        next if found.nil?

        index = 0
        found.codons.times do 
          index <<= @codon.bit_size

          position = @used_length.divmod( genome.size ).last         
          @used_length += 1

          index += @codon.raw_read genome.at(position)
        end

        token.data = found.mapping(index)
      end
    end

    def modify_expansion_generate( exp, genome )
      return unless defined? @embedded
      exp.each do |token|
        next unless token.type == :literal 
        found = @embedded.fetch( token.data, nil )
        next if found.nil?

        index = 0
        found.codons.times do 
          index <<= @codon.bit_size
          value = @codon.rand_gen
          index += value
          genome.push value
        end

        token.data = found.mapping(index)
      end
    end

  end

end # Mapper

