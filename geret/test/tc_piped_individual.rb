#!/usr/bin/ruby

require 'test/unit'
require 'lib/piped_individual'

include Util

class MockMapper2
  def initialize
    @used_length = 5
    @complexity = 10
  end

  def phenotype genotype 
    "some creative phenotype"
  end

  def track_support
    ['track']
  end
  
  attr_reader :used_length
end

class TC_PipedIndividual < Test::Unit::TestCase
  
  def setup
    @mapper = MockMapper2.new
  end

  def test_attributes_1
    outputs = [ {:fitness=>'to_f'}, {:consumption=>'to_i'} ] 
    PipedIndividual.pipe_output( outputs )

    par = {:some=>'minimize', :used_length=>:minimize, :fitness=>'maximize'}    
    PipedIndividual.pareto( par )

    pi = PipedIndividual.new( @mapper, [ 42, 43 ] )
    pi.parse = " 3.43  50"
    assert_equal( 3.43, pi.fitness )
    assert_equal( 50, pi.consumption )
    assert_equal( 5, pi.used_length )   
    assert_equal( nil, pi.some )
    assert_equal( [:some, :used_length, :fitness], pi.objective_symbols )
  end

  def test_attributes_2
    par = {:some=>'minimize', :used_length=>:minimize, :fitness=>'maximize'}    
    PipedIndividual.pareto( par )

    outputs = [ {:fitness=>'to_f'}, {:consumption=>'to_i'} ] 
    PipedIndividual.pipe_output( outputs )

    pi = PipedIndividual.new( @mapper, [ 42, 43 ] )
    pi.parse = "3.43  50  "
    assert_equal( 3.43, pi.fitness )
    assert_equal( 50, pi.consumption )
    assert_equal( 5, pi.used_length )   
    assert_equal( nil, pi.some )
    assert_equal( [:some, :used_length, :fitness], pi.objective_symbols )
  end
 
  def test_wrong_direction
    par =  {:some=>'minimize', :used_length=>'UNKNOWN', :fitness=>'maximize'}     
    exception = assert_raise( RuntimeError ) {  PipedIndividual.pareto( par ) }
    assert_equal( "PipedIndividual:wrong objective direction 'UNKNOWN' for objective 'used_length'", exception.message )
  end

  def test_both_weak_and_strong
    par =  {:x=>:minimize} 
    PipedIndividual.pareto( par )
    first = PipedIndividual.new( @mapper, [] )
    first.x = 42
    second = PipedIndividual.new( @mapper, [] )
    second.x = 42
    assert_equal( false, first.dominates?( second ) )

    par =  {:x=>:minimize} 
    PipedIndividual.weak_pareto( par )
    first = PipedIndividual.new( @mapper, [] ) 
    first.x = 42
    second = PipedIndividual.new( @mapper, [] ) 
    second.x = 42
    assert_equal( true, first.dominates?( second ) )
  end

  def test_parse_pipe_wrong_size
    outputs = [ {:fitness=>'to_f'}, {:consumption=>'to_i'} ] 
    PipedIndividual.pipe_output( outputs )
    pi = PipedIndividual.new( @mapper, [] )

    exception = assert_raise( RuntimeError ) { pi.parse = "3.43  50 3" }
    assert_equal( "PipedIndividual: parse= expecting 2 items, got 3", exception.message )
  end

  def test_mark_phenotype
    pi = PipedIndividual.new( @mapper, [] )
    assert_equal( "some creative phenotype", pi.phenotype )

    PipedIndividual.mark_phenotype(' FOO')
    pi = PipedIndividual.new( @mapper, [] )
    assert_equal( "some creative phenotype FOO", pi.phenotype )
  end

  def test_mark_batch
    pi = PipedIndividual.new( @mapper, [] )
    assert_equal( '', pi.batch_mark )

    PipedIndividual.mark_batch('RUN_NOW')
    pi = PipedIndividual.new( @mapper, [] )
    assert_equal( 'RUN_NOW', pi.batch_mark )
  end

  def test_thresholds
    thresh = { :fitness=>35.0, :consumption=>8 }
    PipedIndividual.thresholds thresh

    outputs = [ {:fitness=>'to_f'}, {:consumption=>'to_i'} ] 
    PipedIndividual.pipe_output( outputs )

    par =  {:consumption=>:minimize, :fitness=>'maximize'}    
    PipedIndividual.pareto( par )

    pi = PipedIndividual.new( @mapper, [] )
    pi.parse = "34.0  10"
    assert_equal( false, pi.stopping_condition )
    pi.parse = "35.5  10"
    assert_equal( false, pi.stopping_condition )
    pi.parse = "34.0 5"
    assert_equal( false, pi.stopping_condition )
    pi.parse = "35.5 5"
    assert_equal( true, pi.stopping_condition )
  end

  def test_thresholds_dir_not_known
    thresh = { :fitness=>35.0, :consumption=>8 }
    PipedIndividual.thresholds thresh

    outputs = [ {:fitness=>'to_f'}, {:consumption=>'to_i'} ] 
    PipedIndividual.pipe_output( outputs )

    par =  {:fitness=>'maximize'}     
    PipedIndividual.pareto( par )

    pi = PipedIndividual.new( @mapper, [] )
    pi.parse = "38.0  4"
    
    exception = assert_raise( RuntimeError ) { pi.stopping_condition }
    assert_equal( "PipedIndividual: optimisation direction not known for the objective 'consumption'", exception.message )
  end
 
  def test_schema
    outputs = [ {:fitness=>'to_f'}, {:consumption=>'to_i'} ] 
    PipedIndividual.pipe_output( outputs )

    assert_equal( [:fitness, :consumption], PipedIndividual.pipe_schema )

    par = {:consumption=>'minimize', :used_length=>:minimize, :fitness=>'maximize'}    
    PipedIndividual.pareto( par )

    assert_equal( false, PipedIndividual.symbol_maximized?( :used_length ) )
    assert_equal( true, PipedIndividual.symbol_maximized?( :fitness ) )
    assert_equal( false, PipedIndividual.symbol_maximized?( :consumption ) )

    exception = assert_raise( RuntimeError ) { PipedIndividual.symbol_maximized?( :unknown )  }
    assert_equal( "PipedIndividual: symbol 'unknown' not known", exception.message )
  end
 
end

