
$LOAD_PATH << '.'

require 'lib/abnf_file'

def format_syms symbols
  symbols.map{|s| "<#{s}>"}.join(', ')
end

###

abort "use:\n #$0 some.abnf\n" unless ARGV.size==1

g = Abnf::FileLoader.new ARGV[0]  
puts "start symbol: <#{g.start_symbol}>"
undefined = Mapper::Validator.check_undefined g
puts "undefined symbols: " + format_syms( undefined )
unused = Mapper::Validator.check_unused g
puts "not referenced symbols: " + format_syms( unused )
puts ''

abort "recursivity cannot be analyzed." unless undefined.empty? 

g = Mapper::Validator.analyze_recursivity( g )
puts "recursivity :terminating symbols: " + format_syms( g.symbols.find_all {|s| g[s].recursivity == :terminating } )
puts "recursivity :cyclic symbols: " + format_syms( g.symbols.find_all {|s| g[s].recursivity == :cyclic } )
puts "recursivity :infinite symbols: " + format_syms( g.symbols.find_all {|s| g[s].recursivity == :infinite } )
puts "grammar is #{g[g.start_symbol].recursivity}."
puts ''

Validator.analyze_sn_altering g
puts "altering :structural symbols: " + format_syms( g.symbols.find_all {|s| g[s].sn_altering == :structural } )
puts "altering :nodal symbols: " + format_syms( g.symbols.find_all {|s| g[s].sn_altering == :nodal } )
puts ''

Validator.analyze_min_depth g
g.symbols.each do |symbol|
  rule = g[symbol] 
  puts "Rule: <#{symbol}> recursivity: :#{rule.recursivity}; min_depth=#{rule.min_depth}" 

  rule.each do |alt|
    print "  RuleAlt: recursivity: :#{alt.recursivity}; min_depth=#{alt.min_depth}\n    "
    alt.each do |token|
      case token.type
        when :literal
          print '"' + token.data.gsub(/\n/,'\\n') + '"'
        when :symbol
          print '<' + token.data + '>'
        else
          raise "unsupported token.type=#{token.type}"
      end
      print ' '     
    end
    print "\n"
  end
  print "\n"
end

