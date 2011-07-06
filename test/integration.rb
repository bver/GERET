#!/usr/bin/ruby
 
def cmd command
  puts "running #{command}"
  abort " #{command} failed" unless system( command + ' 1>/dev/null' )
end

def run yaml
  cmd 'tools/evolve.rb --algorithm-termination-max_steps=3 ' + yaml
end

system "rm -rf *.store"
system 'rm -rf /tmp/adder_*'

cmd "tools/abnf2abnf.rb sample/abnf/example.abnf"
cmd "tools/abnf_analyze.rb sample/abnf/example.abnf" 
cmd "tools/sensible_init.rb -n 7 -d 7 -m grow sample/toy_regression/generational.yaml |tools/gpmap.rb -u sample/toy_regression/generational.yaml"
cmd "tools/semantic_check.rb sample/ant_trail_tcc/attr_grammar/grammar.abnf  sample/ant_trail_tcc/attr_grammar/semantic.yaml 2>/dev/null"

run "sample/fcl_synthesis/generational.yaml"
run "sample/fcl_synthesis/spea2_lhsc.yaml"

# GHDL is not "easily" installable:
#run "sample/vhdl_design/spea2_lhsc.yaml"

run "sample/toy_regression/generational.yaml"
run "sample/toy_regression/generational_lhsc.yaml"
run "sample/toy_regression/mu_comma_lambda.yaml"
run "sample/toy_regression/mu_plus_lambda.yaml"
run "--algorithm-population_size=50 sample/toy_regression/nsga2.yaml"
run "sample/toy_regression/paretogp_simplified.yaml"
run "sample/toy_regression/spea2.yaml"
run "sample/toy_regression/spea2_lhsc.yaml"
run "sample/toy_regression/steady_state.yaml"

run "sample/santa_fe_ant_trail/generational.yaml"
run "sample/santa_fe_ant_trail/mu_comma_lambda.yaml"
run "sample/santa_fe_ant_trail/mu_plus_lambda.yaml"
run "sample/santa_fe_ant_trail/nsga2.yaml"
run "sample/santa_fe_ant_trail/paretogp_simplified.yaml"
run "sample/santa_fe_ant_trail/spea2.yaml"
run "sample/santa_fe_ant_trail/steady_state.yaml"
run "sample/santa_fe_ant_trail/steady_state_lhsc.yaml"

run "sample/ant_trail_tcc/generational.yaml"
run "sample/ant_trail_tcc/mu_plus_lambda.yaml"
run "sample/ant_trail_tcc/nsga2.yaml"
run "sample/ant_trail_tcc/paretogp_simplified.yaml"
run "sample/ant_trail_tcc/spea2.yaml"
run "sample/ant_trail_tcc/steady_state.yaml"
run "sample/ant_trail_tcc/alps.yaml"
run "sample/ant_trail_tcc/alps_strict.yaml"
run "sample/ant_trail_tcc/paretoalps.yaml"

run "sample/pid/aht.yaml"

run "sample/ant_trail_tcc/attr_grammar/spea2.yaml"

puts "integration tests 'runnable'."
