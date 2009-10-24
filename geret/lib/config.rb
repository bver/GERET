
require 'yaml'

module Util

# The main configuration component of the GERET library. The ConfigYaml instance loads the file with the YAML syntax
# and provides the configuration values and the generic factory for the creation of Ruby classes.
# This facility allows the separation of the generic GE algorithm from its internal classes using the 
# "Injection of control" design pattern.
#
class ConfigYaml < Hash

  # Load the YAML _file_ and prepare the hash of configuration values.
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
  # the cfg['selector']  will be the hash of factory configuration values:
  #   {'class'=>'MySelector', 'require'=>'myselector_class.rb', 'attribute1'=>3, 'attr2'=>'something'}
  #   
  # the cfg['option1'] will contain the value 42
  # and, the cfg['composite_option'] will be: 
  #   { 'level1' => {'level2'=>'foo'} }
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
  # The _key_ section has to be present in the configuration, the _class_ subsection contains the name of the class.
  # All remaining _args_ of the factory method are then passed as the constructor arguments.
  # The optional _require_ subsection the file with the class implementation (all GERET's own classes are automatically 
  # present via require 'lib/geret'). 
  # Remaining subsections are considered as attributes and their values are assigned to the newly created instance.
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
  # is equivalent to:
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

    static_keys = details.keys.find_all { |k| k[0] == '_' } 
    static_keys.each do |k|
      method = k.sub( /^_/, '' )
      text = "#{klass}.#{method}( #{ details[k].inspect } )"
      eval text 
    end

    begin
      instance = eval text
    rescue => details
      raise "ConfigYaml: cannot eval '#{text}' (missing require?)\n" + details.inspect
    end

    details.each_pair do |k,value|
      next if ['class','initialize', 'require'].include? k
      next if k[0] == '_' # no class methods, please
      eval "instance.#{k} = #{value.inspect}"
    end

    instance
  end

  # This helper function takes the _options_ hash and overloads its values according the args.
  # Note the '-' character separates the level of the hashing.
  # 
  # For example:
  # 
  #   args = ['file.txt', '--arg=12', '--no', '--opt-sub=xyz', 'file2.out', '--opt-sub2-sub3=4.4']
  #   opts = ConfigYaml.parse_options( args, {'orig'=>42, 'arg'=>'22'} )
  #   
  # opts will be:
  #   { 'orig'=>42, 'arg'=>12, 'no'=>nil, 'opt'=>{'sub'=>'xyz', 'sub2'=>{'sub3'=>4.4} }  }
  #
  def ConfigYaml.parse_options( args, options = {} )
    args.each do |arg|
      next unless /^--/ =~ arg
      key, value = arg.sub( /^--/, '' ).split('=')
      value = value.to_i if value.to_i.to_s == value
      value = value.to_f if value.to_f.to_s == value     
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

  # This helper function removes all items beginning with '--' from the argument array.
  # Eg.: 
  #   ARGV = ['file.txt', '--option=42', 'file2.txt', '--quiet', '-x', 'output.txt']
  #   ConfigYaml.remove_options! ARGV
  #   
  # ARGV is now:
  #   ['file.txt', 'file2.txt', '-x', 'output.txt']
  #
  def ConfigYaml.remove_options! args
    args.delete_if { |arg| /^--/ =~ arg }
  end

end

end # Util
