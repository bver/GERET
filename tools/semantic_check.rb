#!/usr/bin/ruby

require 'lib/abnf_file'
require 'lib/semantic_functions'

abort "use:\n #$0 gramar.abnf semantic.yaml\n" unless ARGV.size==2

begin

  grammar = Abnf::File.new ARGV[0]
  semantic = Semantic::Functions.new( IO.read( ARGV[1] ) )

  usage = {}
  usage.default = 0

  grammar.each_pair do |symbol,rule|
    snode = semantic.fetch( symbol, nil )
    raise "ERROR: symbol '#{symbol}' not found in the semantic file." if snode.nil?

    rule.each do |alt|
      skey = Semantic::Functions.match_key( alt )

      exprule = "#{symbol} -> #{skey}"
      puts exprule     
     
      srule = snode.fetch( skey, nil )
      if srule.nil?
        srule = snode.fetch( '*', nil ) 
        raise "ERROR: rule '#{exprule}' not described by the semantic file." if srule.nil?
        exprule = "#{symbol} -> *" 
      end

      usage[ exprule ] += 1

      semantic.node_expansion( Mapper::Token.new(:symbol,symbol), alt ).each do |func|
        print "  #{ semantic.render_attr(func.target) } = { |"
        print ( func.args.map { |a| semantic.render_attr a } ).join(',')
        puts "| #{func.orig} }"
      end

    end
  end

  semantic.each_pair do |symbol,rules|
    rules.keys.each do |key|
      exprule = "#{symbol} -> #{key}"
      next if usage[ exprule ] > 0
      puts "WARNING: semantic functions under '#{exprule}' not used by the grammar."
    end
  end

rescue => msg
  abort msg.to_s
end

