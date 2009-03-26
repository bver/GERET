
require 'yaml'

class ConfigYaml < Hash
  def initialize file=nil
    super()
    return if file.nil?

    update YAML::load( File.open( file ) )
  end

  def factory key, *args
    details = fetch(key,nil)
    initial_args = if args.empty? 
                     details['initialize']
                   else
                     ( args.map {|a| a.inspect} ).join ', '
                   end

    instance = eval "#{details['class']}.new( #{initial_args} )"

    details.each_pair do |key,value|
      next if ['class','initialize'].include? key #later: require
      eval "instance.#{key} = #{value.inspect}"
    end
    instance
  end

end

