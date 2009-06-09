
require 'yaml'

# The main configuration tool of GERET. The ConfigYaml instance loads the file with the YAML syntax
# and provides the configuration values and the factory for the creation of Ruby classes.
# This facility allows the separation of the generic GE algorithm from its internal classes.
class ConfigYaml < Hash

  # Load the YAML file and prepare the hash of configuration values.
  # For example, if the file.yaml contains this text:
  # 
  #   selector: 
  #     class: MySelector
  #     require: myselector_class.rb
  #     attribute1: 3
  #     attr2: something 
  #   option1: 42
  #   composite_option:
  #     level1:
  #       level2: foo
  #    
  # then, after the calling:
  # 
  #   cfg = ConfigYaml.new('file.yaml') 
  #   
  #   the cfg['selector']  will be the hash of factory configuration values:
  #   {'class'=>'MySelector', 'require'=>'myselector_class.rb', 'attribute1'=>3, 'attr2'=>'something'}
  #   
  #   the cfg['option1'] will contain the value 42
  #   
  #   and, the cfg['composite_option'] will be { 'level1' => {'level2'=>'foo'} }
  #   
  def initialize file=nil
    super()
    return if file.nil?

    obj = YAML::load( File.open( file ) )   
    raise "ConfigYaml: top level yaml object is not a hash" unless obj.kind_of? Hash
    update obj 

    each_value do |details|
      requirement = details.fetch( 'require', nil )
      require requirement unless requirement.nil?
    end
  end

  # Create the instance of the class which is dynamically specified by the YAML file.
  # 
  # For example, if the file.yaml contains this text:
  #
  #   selector: 
  #     class: MySelector
  #     require: myselector_class.rb
  #     attribute1: 3
  #     attr2: something 
  #
  # then the code: 
  # 
  #   cfg = ConfigYaml.new('file.yaml') 
  #   sel = cfg.factory( 'selector', 'my_1st_arg', '2nd_one' )
  #   
  # is equivalent of:
  # 
  #   require 'myselector_class.rb'
  #   sel = MySelector.new( 'my_1st_arg', '2nd_one' )
  #   sel.attribute1 = 3
  #   sel.attr2 = 'something'
  #
  def factory( key, *args )
    details = fetch( key, nil )
    raise "ConfigYaml: missing key when calling factory('#{key}')" if details.nil?
    klass = details.fetch( 'class', nil )
    raise "ConfigYaml: missing class when calling factory('#{key}')" if klass.nil?

    requirement = details.fetch( 'require', nil )
    require requirement unless requirement.nil?
   
    if args.empty?
      text = "#{klass}.new( #{ details.fetch( 'initialize', '' ) } )" 
    else
      text = "#{klass}.new( "
      args.each_index { |index| text += "args[#{index}]," }
      text = text[ 0...text.size-1 ] + ' )'
    end

    begin
      instance = eval text
    rescue => details
      raise "ConfigYaml: cannot eval '#{text}' (missing require?)\n" + details.inspect
    end

    details.each_pair do |k,value|
      next if ['class','initialize', 'require'].include? k
      eval "instance.#{k} = #{value.inspect}"
    end

    instance
  end

  def ConfigYaml.parse_options( args, options = {} )
    args.each do |arg|
      next unless /^--/ =~ arg
      key, value = arg.sub( /^--/, '' ).split('=')
      hsh = options 
      keys = key.split(/-/)
      while keys.size > 1
        k = keys.shift
        hsh[k] = {} unless hsh.has_key? k
        hsh = hsh[k]
      end
      hsh[ keys.last ] = value
    end
    options
  end

  def ConfigYaml.remove_options! args
    args.delete_if { |arg| /^--/ =~ arg }
  end

end

