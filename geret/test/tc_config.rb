#!/usr/bin/ruby

require 'test/unit'
require 'lib/config'

class FactoryArtifact
  def initialize arg1, arg2, arg3
    @arg1 = arg1
    @arg2 = arg2
    @arg3 = arg3   
    @attr1 = 'undef'
    @attr2 = 'undef'
    @attr3 = 'undef'   
  end

  attr_reader :arg1, :arg2
  attr_accessor :arg3, :attr1, :attr2, :attr3
end

class TC_Config < Test::Unit::TestCase

  def test_values
    cfg = ConfigYaml.new
    cfg.update( { :variable1 => 1, 'variable2' => 'value2' } )
    cfg[:var3] = 42

    assert_equal( 1, cfg[:variable1] )
    assert_equal( 'value2', cfg['variable2'] )
    assert_equal( 42, cfg[:var3] )  
    assert_equal( nil, cfg['unknown'] ) 
  end

  def test_yaml
    cfg = ConfigYaml.new  'test/data/config.yaml'

    assert_equal( {'class'=>'MyMapper', 'initialize'=>'file.abnf'}, cfg['mapper'] )
    assert_equal( {'class'=>'MySelector', 'require'=>'MySelector.rb', 'attribute1'=>3, 'attr2'=>'toto'}, cfg['selector'] )
  end

  def test_factory
    cfg = ConfigYaml.new
    cfg['artifact'] = {'class'=>'FactoryArtifact', 'initialize'=>"1, '2nd', 'overwritten'",
                       'arg3'=>'patch', 'attr1'=>'one', 'attr2'=>2 }
    
    instance1 = cfg.factory('artifact')
    assert_equal( FactoryArtifact, instance1.class )
    assert_equal( 1, instance1.arg1 )
    assert_equal( '2nd', instance1.arg2 )
    assert_equal( 'patch', instance1.arg3 )
    assert_equal( 'one', instance1.attr1 )
    assert_equal( 2, instance1.attr2 )
    assert_equal( 'undef', instance1.attr3 )   

    instance2 = cfg.factory('artifact', 42, 'my', 'arguments')
    assert_equal( FactoryArtifact, instance2.class )
    assert_equal( 42, instance2.arg1 )
    assert_equal( 'my', instance2.arg2 )
    assert_equal( 'patch', instance2.arg3 )
    assert_equal( 'one', instance2.attr1 )
    assert_equal( 2, instance2.attr2 )
    assert_equal( 'undef', instance2.attr3 )   
  end

  def test_require
  end

  def test_missing_key
  end

  def test_missing_initialize
  end
 
  def test_missing_class
  end

end
