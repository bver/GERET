
require 'yaml'

class ConfigYaml < Hash

  def initialize file=nil
    super()
    return if file.nil?

    obj = YAML::load( File.open( file ) )   
    raise "ConfigYaml: top level yaml object is not a hash" unless obj.kind_of? Hash
    update obj 
  end

  def factory key, *args
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

end

