
#
# = Modules (namespaces) of GERET
# 
# Abnf - Augmented Backus-Naur Form support (mainly parsing *.abnf files to grammar instances)
#
# Mapper - GE core classes (grammar, genotype->phenotype mapping, genotype initialization...)
#
# Moea - Multiple Optimisation Evolutionary Algorithms support (pareto, dominance metrics...)
# 
# Operator - genetic operators (various crossover and mutations...)
# 
# Selection - selection operators (tournament, SUS, roulete, etc. population operators)
#
# Semantic - attribute grammars support (semantic attributes, semantic functions)
# 
# Util - auxilary classes (configuration, pipe interface, serialisation, etc. classes)
#
# = Requires
# This file is the common "require proxy" for GERET library (require 'lib/geret' uses the library as a whole ).
# When extending the library, please add require statement for every new dependency which should be considered 
# as a part of lib/* or algorithm/*
#

require 'lib/abnf_renderer'
require 'lib/abnf_file'
require 'lib/config'
require 'lib/crossover_ripple'
require 'lib/crossover_lhs'
require 'lib/crossover_twopoints'
require 'lib/dominance'
require 'lib/mapper'
require 'lib/mutation_ripple'
require 'lib/mutation_altering'
require 'lib/mutation_simplify'
require 'lib/crowding'
require 'lib/random_init'
require 'lib/report'
require 'lib/rank_roulette'
require 'lib/rank_sampling'
require 'lib/shorten'
require 'lib/store'
require 'lib/tournament'
require 'lib/utils'
require 'lib/validator'
require 'lib/individual'
require 'lib/truncation'
require 'lib/round_robin'
require 'lib/pareto_tourney'
require 'lib/work_pipes'
require 'lib/piped_individual'
require 'lib/attribute_grammar'
require 'lib/codon_bucket'
require 'lib/codon_gray'

require 'algorithm/generational'
require 'algorithm/steady_state'
require 'algorithm/mu_lambda'
require 'algorithm/paretogp_simplified'
require 'algorithm/nsga2'
require 'algorithm/spea2'
require 'algorithm/alps'
require 'algorithm/alps_strict'
require 'algorithm/support/population_report'
require 'algorithm/age_hierarchy_tree'

