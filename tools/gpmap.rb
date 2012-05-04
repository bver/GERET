
$LOAD_PATH << '.'

#
# gpmap: map genotype to phenotype
#
# usage:
#   tools/gpmap.rb [OPTIONS] config.yaml < genotype > phenotype
#
# -h, --help:
#    show help
#
# -t, --track:
#    print track support info (for the LHS crossover)
#
# -u, --used:
#    print number of codons used for GP mapping
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
# genotype is read from STDIN and has the form of ruby array:
#   eg: [42, 23, 34, 4]
#
# phenotype is written to STDOUT and its syntax is specified
#   by the grammar
#    

require 'getoptlong'
require 'lib/geret'

begin

  opts = GetoptLong.new(
    [ "--track", '-t', GetoptLong::NO_ARGUMENT ],
    [ "--used", '-u', GetoptLong::NO_ARGUMENT ],
    [ "--help", '-h', GetoptLong::NO_ARGUMENT ],
    [ "--supress", '-s', GetoptLong::NO_ARGUMENT ]   
  )
 
  used = false
  track = false
  supress = false
  opts.each do |opt, arg|
    case opt
      when '--help'
        #RDoc::usage replacement:
        IO.read( $0 ).each_line do |line|
          matched = /#\s(.*)$/.match line
          puts matched[1] unless matched.nil?
        end 
        exit 0
      when '--used'
        used = true
      when '--track'
        track = true
      when '--supress'
        supress = true
    end
  end
  
  raise "Missing config.yaml argument, try --help" if ARGV.length != 1
  
  config = ConfigYaml.new ARGV.shift
  grammar = config.factory('grammar')
  mapper = config.factory('mapper', grammar)
  mapper.track_support_on = track

  $stdin.each_line do |chromozome|
    genotype = eval chromozome
    next unless genotype.kind_of? Array
    phenotype = mapper.phenotype genotype 
    next if phenotype.nil?
    puts phenotype unless supress
    mapper.track_support.each_with_index do |node,i| 
      text = (grammar[node.symbol][node.alt_idx].map {|token| token.type == :symbol ? %Q[<#{token.data}>] : %Q["#{token.data}"] }).join(' ')
      puts "#{i}. #{node.symbol} genome:#{node.from}..#{node.to} parent:#{node.back} locus:#{node.loc_idx} expansion:'#{text}'"
    end if track
    puts "used_length = #{mapper.used_length}" if used
  end

rescue => msg
  abort msg.to_s
end

