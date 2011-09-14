
$LOAD_PATH << '.' unless $LOAD_PATH.include? '.'

require 'test/unit'
require 'lib/grammar'
require 'lib/mapper_constants'

class ConstCodonMock
  def initalize seq
    @seq = seq
  end

  def raw_read codon
    codon
  end

  def rand_gen
    @seq.shift
  end

  def bit_size
    3
  end
end

class ConstantsTest
  include Mapper::ConstantsInGenotype
  def initialize
    @used_length = 0
    @codon = ConstCodonMock.new
  end
  attr :used_length
end

class TC_MapperConstants < Test::Unit::TestCase

  TestExpansion = [
       Mapper::Token.new( :literal, '*' ),
       Mapper::Token.new( :literal, '_con2' ), 
       Mapper::Token.new( :literal, 'const1' ),                 
       Mapper::Token.new( :literal, '_const' ),
       Mapper::Token.new( :symbol, 'const1' ),               
       Mapper::Token.new( :literal, 'xyz' ),      
       Mapper::Token.new( :literal, '_con2' )                       
    ]
 
  def test_base
    mapper = ConstantsTest.new
    assert_equal( 0, mapper.used_length )
    assert_equal( nil, mapper.embedded )

    genome = [2,3]
    ext = TestExpansion.map { |t| t.clone }

    mapper.modify_expansion_base( ext, genome )
    assert_equal( 0, mapper.used_length )   
    assert_equal( TestExpansion, ext )

    mapper.embedded_constants = {"const1"=>{"codons"=>1, "min"=>-2.5, "max"=>1.0}}
    assert_equal( [-2.5, -2.0, -1.5, -1.0, -0.5, 0.0, 0.5, 1.0], mapper.embedded['const1'].mapping ) 
    # 000 ~ -2.5 
    # 001 ~ -2.0
    # 010 ~ -1.5
    # 011 ~ -1.0
    # 100 ~ -0.5
    # 101 ~ 0.0
    # 110 ~ 0.5
    # 111 ~ 1.0
   
    mapper.modify_expansion_base( ext, genome )
    assert_equal( 1, mapper.used_length )   
    assert_equal( TestExpansion[0], ext[0] )
    assert_equal( TestExpansion[1], ext[1] )
    assert_equal( -1.5, ext[2].data )
    assert_equal( :literal, ext[2].type )   
    assert_equal( TestExpansion[3], ext[3] )
    assert_equal( TestExpansion[4], ext[4] )
    assert_equal( TestExpansion[5], ext[5] )
    assert_equal( TestExpansion[6], ext[6] )
  end

  def test_two_consts
    mapper = ConstantsTest.new

             #_con2  #const1  #_con2   #tail
    genome = [6,3,   6,       2,5,     4,4,4]
    ext = TestExpansion.map { |t| t.clone }

    mapper.embedded_constants = {
       "const1"=>{ "min"=>-2.5, "max"=>1 }, 
       "_con2"=>{"codons"=>2, "min"=>2, "max"=>63002} 
    } 
    # 000000 ~ 2
    # 000001 ~ 1002
    # 000010 ~ 2002
    # ...
    # 010101 ~ 2+1000*21 = 21002
    # ...    
    # 110011 ~ 2+1000*51 = 51002
    # ...
    # 111111 ~ 63002

    assert_equal( 2, mapper.embedded['_con2'].codons )  
    assert_equal( 1, mapper.embedded['const1'].codons ) #implicit default
    assert_equal( Integer, mapper.embedded['_con2'].type )  
    assert_equal( Float, mapper.embedded['const1'].type )

    assert_equal( [-2.5, -2.0, -1.5, -1.0, -0.5, 0.0, 0.5, 1.0], mapper.embedded['const1'].mapping )    

    assert_equal( 64, mapper.embedded['_con2'].mapping.size )  
    assert_equal( 2, mapper.embedded['_con2'].mapping[0] )    
    assert_equal( 63002, mapper.embedded['_con2'].mapping[63] )  
    assert_equal( 51002, mapper.embedded['_con2'].mapping[51] ) # 51 = 6 << 3 + 3  
    assert_equal( 21002, mapper.embedded['_con2'].mapping[21] ) # 21 = 2 << 3 + 5  
  
    mapper.modify_expansion_base( ext, genome )
    assert_equal( TestExpansion[0], ext[0] )
    assert_equal( 51002, ext[1].data )
    assert_equal( 0.5, ext[2].data )   
    assert_equal( TestExpansion[3], ext[3] )
    assert_equal( TestExpansion[4], ext[4] )
    assert_equal( TestExpansion[5], ext[5] )
    assert_equal( 21002, ext[6].data )

    assert_equal( 5, mapper.used_length )   
  end

  def test_wrong_config
    mapper = ConstantsTest.new   
    exception = assert_raise( RuntimeError ) { mapper.embedded_constants = {"c1"=>{"max"=>1.0}} }
    assert_equal( "ConstantsInGenotype: missing min for constant 'c1'", exception.message )   

    mapper = ConstantsTest.new   
    exception = assert_raise( RuntimeError ) { mapper.embedded_constants = {"c1"=>{"min"=>1.0, "max_blahblah"=> 42}} }
    assert_equal( "ConstantsInGenotype: missing max for constant 'c1'", exception.message )   
  end

  def test_genome_wrapping
    mapper = ConstantsTest.new

             #_con2  #const1  #_con2 
    genome = [6,3]   #6       3,6
    ext = TestExpansion.map { |t| t.clone }

    mapper.embedded_constants = {
       "const1"=>{ "min"=>-2.5, "max"=>1 }, 
       "_con2"=>{"codons"=>2, "min"=>2, "max"=>63002} 
    } 
    assert_equal( 63002, mapper.embedded['_con2'].mapping[63] )  
    assert_equal( 30002, mapper.embedded['_con2'].mapping[30] ) # 30 = 3 << 3 + 6  
  
    mapper.modify_expansion_base( ext, genome )
    assert_equal( TestExpansion[0], ext[0] )
    assert_equal( 51002, ext[1].data )
    assert_equal( 0.5, ext[2].data )   
    assert_equal( TestExpansion[3], ext[3] )
    assert_equal( TestExpansion[4], ext[4] )
    assert_equal( TestExpansion[5], ext[5] )
    assert_equal( 30002, ext[6].data )

    assert_equal( 5, mapper.used_length )   #wrapped:  5 % genome.size
  end

end



