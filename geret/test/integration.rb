#!/usr/bin/ruby

Command = 'tools/evolve.rb --algorithm-termination-max_steps=2 '
system "rm *.store"

abort "toy_regression/generational failed" unless system Command+" sample/toy_regression/generational.yaml"
abort "toy_regression/mu_comma_lambda failed" unless system Command+" sample/toy_regression/mu_comma_lambda.yaml"
abort "toy_regression/mu_plus_lambda failed" unless system Command+" sample/toy_regression/mu_plus_lambda.yaml"
abort "toy_regression/nsga2 failed" unless system Command+" sample/toy_regression/nsga2.yaml"
abort "toy_regression/pareto_naive failed" unless system Command+" sample/toy_regression/pareto_naive.yaml"
abort "toy_regression/paretogp_simplified failed" unless system Command+" sample/toy_regression/paretogp_simplified.yaml"
abort "toy_regression/spea2 failed" unless system Command+" sample/toy_regression/spea2.yaml"
abort "toy_regression/steady_state failed" unless system Command+" sample/toy_regression/steady_state.yaml"

abort "santa_fe_ant_trail/generational failed" unless system Command+" sample/santa_fe_ant_trail/generational.yaml"
abort "santa_fe_ant_trail/mu_comma_lambda failed" unless system Command+" sample/santa_fe_ant_trail/mu_comma_lambda.yaml"
abort "santa_fe_ant_trail/mu_plus_lambda failed" unless system Command+" sample/santa_fe_ant_trail/mu_plus_lambda.yaml"
abort "santa_fe_ant_trail/nsga2 failed" unless system Command+" sample/santa_fe_ant_trail/nsga2.yaml"
abort "santa_fe_ant_trail/pareto_naive failed" unless system Command+" sample/santa_fe_ant_trail/pareto_naive.yaml"
abort "santa_fe_ant_trail/paretogp_simplified failed" unless system Command+" sample/santa_fe_ant_trail/paretogp_simplified.yaml"
abort "santa_fe_ant_trail/spea2 failed" unless system Command+" sample/santa_fe_ant_trail/spea2.yaml"
abort "santa_fe_ant_trail/steady_state failed" unless system Command+" sample/santa_fe_ant_trail/steady_state.yaml"

puts "integration tests ok."
