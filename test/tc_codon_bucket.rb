#!/usr/bin/ruby

require 'test/unit'
require 'test/mock_rand'
require 'lib/grammar'
require 'lib/codon_bucket'

class TC_CodonBucket < Test::Unit::TestCase

  def setup
    @grammar = Mapper::Grammar.new( {
      'alpha' => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'A' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'B' ) ] )
                ] ),

      'expr' => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'x' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, 'y' ) ] ),
                  Mapper::RuleAlt.new( [ 
                    Mapper::Token.new( :literal, '(' ), 
                    Mapper::Token.new( :symbol, 'expr' ),
                    Mapper::Token.new( :literal, ' ' ),                   
                    Mapper::Token.new( :symbol, 'op' ),                  
                    Mapper::Token.new( :symbol, 'expr' ),                   
                    Mapper::Token.new( :literal, ')' ) 
                  ] )
                ] ),

       'op'  => Mapper::Rule.new( [ 
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '+' ) ] ),
                  Mapper::RuleAlt.new( [ Mapper::Token.new( :literal, '*' ) ] )
                ] )
    }, 'expr' )
   
  end

  def test_basic_no_grammar_provided
    
    # fall back to the superclass CodonMod
    
    c = Mapper::CodonBucket.new
    assert_equal( 8, c.bit_size ) #default

    assert_equal( 2, c.interpret( 3, 5 ) )
    assert_equal( 1, c.interpret( 2, 7 ) )

    assert( c.random.kind_of?( Kernel ) ) #default is Kernel.rand
    c.random = MockRand.new [ {85=>1}, {85=>2}, {85=>84} ]

    assert_equal( 5, c.generate( 3, 2 ) )
    assert_equal( 8, c.generate( 3, 2 ) )   
    assert_equal( 254, c.generate( 3, 2 ) )   
  end

  def test_basic_with_grammar
    assert_equal( 2, @grammar['alpha'].size )  # @bucket['alpha'] == 1
    assert_equal( 3, @grammar['expr'].size )  # @bucket['expr'] == 1*2
    assert_equal( 2, @grammar['op'].size )   # @bucket['op'] == 1*2*3
                                            # @max_closure  == 1*2*3*2
    c = Mapper::CodonBucket.new
    assert_equal( nil, c.bucket )
    assert_equal( nil, c.max_closure ) 
    assert_equal( false, c.valid_codon?( 12*256-1 ) ) 

    c.grammar = @grammar
    assert_equal( 3, c.bucket.size )
    assert_equal( 1, c.bucket['alpha'] )
    assert_equal( 2, c.bucket['expr'] )
    assert_equal( 6, c.bucket['op'] )
    assert_equal( 12, c.max_closure )   

    assert_equal( true, c.valid_codon?( 12*256-1 ) )   
    assert_equal( false, c.valid_codon?( 12*256 ) )      

    assert_equal( 1, c.interpret( 2*1, 5, 'alpha' ) )      
    assert_equal( 2, c.interpret( 3*2, 5, 'expr' ) )
    assert_equal( 1, c.interpret( 2*6, 7, 'op' ) )

    assert( c.random.kind_of?( Kernel ) ) #default is Kernel.rand
    c.random = MockRand.new [ {85=>1}, {85=>2}, {85=>84} ]

    assert_equal( 5*1, c.generate( 3, 2, 'alpha' ) )
    assert_equal( 8*2, c.generate( 3, 2, 'expr' ) )   
    assert_equal( 254*6, c.generate( 3, 2, 'op' ) )   

    # fallback with a grammar, without symbol argument:
    assert_equal( 2, c.interpret( 3, 5 ) )
    assert_equal( 1, c.interpret( 2, 7 ) )

    assert( c.random.kind_of?( Kernel ) ) #default is Kernel.rand
    c.random = MockRand.new [ {85=>1}, {85=>2}, {85=>84} ]

    assert_equal( 5, c.generate( 3, 2 ) )
    assert_equal( 8, c.generate( 3, 2 ) )   
    assert_equal( 254, c.generate( 3, 2 ) )   
  end

  def test_mutate
    c = Mapper::CodonBucket.new   
    c.random = MockRand.new [ {8=>1} ]   
    assert_equal( 7, c.mutate_bit( 5 ) ) # falling back to superclass

    c.grammar = @grammar
    assert_equal( 12, c.max_closure )   

    c.random = MockRand.new [ {3+8=>10} ]  # 3+8=11 possible bit positions:
    assert_equal( 1029, c.mutate_bit( 5 ) )   # 00000000101 -> 10000000101
  end

  def test_random_generate
    c = Mapper::CodonBucket.new   
    c.random = MockRand.new [ {256=>3}, {256=>103}, {256=>42} ]   

    # falling back to superclass
    assert_equal( 3, c.rand_gen )      
    assert_equal( 103, c.rand_gen )         
    assert_equal( 42, c.rand_gen )         

    c.grammar = @grammar
    assert_equal( 12, c.max_closure )  

    c.random = MockRand.new [ {256*12=>354}, {256*12=>1030}, {256*12=>3072} ]   
    assert_equal( 354, c.rand_gen )      
    assert_equal( 1030, c.rand_gen )         
    assert_equal( 3072, c.rand_gen )         
  end

end

