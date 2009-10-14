#!/usr/bin/ruby

abort "abnf2abnf failed" unless system "tools/abnf2abnf.rb sample/abnf/example.abnf"
abort "abnf_analyze failed" unless system "tools/abnf_analyze.rb sample/abnf/example.abnf"
abort "sensible_init and gpmap failed" unless system "tools/sensible_init.rb -n 7 -d 7 -m grow sample/toy_regression/generational.yaml |tools/gpmap.rb -u sample/toy_regression/generational.yaml"

Command = 'tools/evolve.rb --algorithm-termination-max_steps=2 '
system "rm *.store"

abort "toy_regression/generational failed" unless system Command+" sample/toy_regression/generational.yaml"
abort "toy_regression/generational_lhsc failed" unless system Command+" sample/toy_regression/generational_lhsc.yaml"
abort "toy_regression/mu_comma_lambda failed" unless system Command+" sample/toy_regression/mu_comma_lambda.yaml"
abort "toy_regression/mu_plus_lambda failed" unless system Command+" sample/toy_regression/mu_plus_lambda.yaml"
abort "toy_regression/nsga2 failed" unless system Command+" --algorithm-population_size=50 sample/toy_regression/nsga2.yaml"
abort "toy_regression/paretogp_simplified failed" unless system Command+" sample/toy_regression/paretogp_simplified.yaml"
abort "toy_regression/spea2 failed" unless system Command+" sample/toy_regression/spea2.yaml"
abort "toy_regression/spea2_lhsc failed" unless system Command+" sample/toy_regression/spea2_lhsc.yaml"
abort "toy_regression/steady_state failed" unless system Command+" sample/toy_regression/steady_state.yaml"

abort "santa_fe_ant_trail/generational failed" unless system Command+" sample/santa_fe_ant_trail/generational.yaml"
abort "santa_fe_ant_trail/mu_comma_lambda failed" unless system Command+" sample/santa_fe_ant_trail/mu_comma_lambda.yaml"
abort "santa_fe_ant_trail/mu_plus_lambda failed" unless system Command+" sample/santa_fe_ant_trail/mu_plus_lambda.yaml"
abort "santa_fe_ant_trail/nsga2 failed" unless system Command+" sample/santa_fe_ant_trail/nsga2.yaml"
abort "santa_fe_ant_trail/paretogp_simplified failed" unless system Command+" sample/santa_fe_ant_trail/paretogp_simplified.yaml"
abort "santa_fe_ant_trail/spea2 failed" unless system Command+" sample/santa_fe_ant_trail/spea2.yaml"
abort "santa_fe_ant_trail/steady_state failed" unless system Command+" sample/santa_fe_ant_trail/steady_state.yaml"
abort "santa_fe_ant_trail/steady_state_lhsc failed" unless system Command+" sample/santa_fe_ant_trail/steady_state_lhsc.yaml"

puts "integration tests 'runnable'."
