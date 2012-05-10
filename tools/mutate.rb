
$LOAD_PATH << '.'

#
# mutate: apply mutation to the genotype
#
# usage:
#   tools/mutate.rb [OPTIONS] config.yaml < genotype > mutant
#
# -h, --help:
#    show help
#
# -g, --genotype:
#    copy the genotype from $stdin before another output
#
# config.yaml is a configuration file with [grammar], [mapper] and [mutation] sections.
# for instance:
#   grammar:
#     class: Abnf::File
#     filename: sample/santa_fe_ant_trail/grammar.abnf
#   mapper:
#     class: DepthBucket
#     consume_trivial_codons: false
#   mutation:
#     class: MutationRipple
#
# genotype is read from STDIN and has the form of ruby array:
#   eg: [42, 23, 34, 4]
#
# mutant is written to STDOUT and its syntax is same
#   as genotype's
#    

require 'getoptlong'
require 'lib/geret'

begin

  opts = GetoptLong.new(
    [ "--help", '-h', GetoptLong::NO_ARGUMENT ],
    [ "--genotype", '-g', GetoptLong::NO_ARGUMENT ]   
  )
 
  mirror = false
  opts.each do |opt, arg|
    case opt
      when '--help'
        #RDoc::usage replacement:
        IO.read( $0 ).each_line do |line|
          matched = /#\s(.*)$/.match line
          puts matched[1] unless matched.nil?
        end 
        exit 0
      when '--genotype'
        mirror = true
    end
  end
  
  raise "Missing config.yaml argument, try --help" if ARGV.length != 1
  
  config = ConfigYaml.new ARGV.shift
  grammar = config.factory('grammar')
  mapper = config.factory('mapper', grammar)
  mapper.track_support_on = true
  mutation = config.factory('mutation', grammar) 

  $stdin.each_line do |chromozome|
    puts chromozome if mirror
    genotype = eval chromozome
    next unless genotype.kind_of? Array
    phenotype = mapper.phenotype genotype 
    next if phenotype.nil?
    puts mutation.mutation( genotype, mapper.track_support ).inspect   
  end

rescue => msg
  abort msg.to_s
end

