
#
# gpmap: map genotype to phenotype
#
# usage:
#   tools/sensible_init.rb [OPTIONS] config.yaml > genotype
#
# -h, --help:
#    show help
#
# -n <N>, --howmuch=<N>:
#    repeat N times (generate N lines with N genotypes, default is 1)
#
# -m, --method=<full|grow>
#    set method ('full' or 'grow', default is 'full')
#
# -d <D>, --depth=<D>:
#    use D levels for generation (default is yaml/algorithm/init/sensible_depth or 3)
#
# config.yaml is a configuration file with [grammar] and [mapper] sections.
# for instance:
#   grammar:
#     class: Abnf::File
#     filename: sample/santa_fe_ant_trail/grammar.abnf
#   mapper:
#     class: DepthBucket
#     consume_trivial_codons: false
#
# genotype(s) is  written to STDOUT and has the form of ruby array:
#   eg: [42, 23, 34, 4]
#

$LOAD_PATH << '.'

require 'getoptlong'
require 'lib/geret'

begin

  opts = GetoptLong.new(
    [ "--depth", '-d', GetoptLong::REQUIRED_ARGUMENT ],
    [ "--method", '-m', GetoptLong::REQUIRED_ARGUMENT ],
    [ "--howmuch", '-n', GetoptLong::REQUIRED_ARGUMENT ],
    [ "--help", '-h', GetoptLong::NO_ARGUMENT ]
  )

  howmuch = 1
  depth_arg = nil
  recursivity = [:cyclic]
  opts.each do |opt, arg|
    case opt
      when '--help'
        #RDoc::usage replacement:
        IO.read( $0 ).each_line do |line|
          matched = /#\s(.*)$/.match line
          puts matched[1] unless matched.nil?
        end 
        exit 0
      when '--depth'
        depth_arg = arg.to_i
      when '--method'
        case arg
        when 'full'
          recursivity = [:cyclic] 
        when 'grow'
          recursivity = [:cyclic, :terminating]       
        else
          raise "method #{arg} is not supported"
        end
      when '--howmuch'
        howmuch = arg.to_i     
    end
  end

  raise "Missing config.yaml argument, try --help" if ARGV.length != 1
  config = ConfigYaml.new ARGV.shift
  if not depth_arg.nil?
    depth = depth_arg
  elsif config['algorithm'].nil? or 
        config['algorithm']['init'].nil? or 
        config['algorithm']['init']['sensible_depth'].nil?
    depth = 3
  else
    depth = config['algorithm']['init']['sensible_depth'].to_i 
  end
 
  grammar = config.factory('grammar')
  mapper = config.factory('mapper', grammar)

  howmuch.times { puts mapper.generate( recursivity, depth ).inspect }

rescue => msg
  abort msg.to_s
end

