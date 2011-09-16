
require 'lib/grammar'
require 'lib/mapper_generator'

module Mapper

  # Mapper class employing the depth-first node expansion strategy:
  #   1. Create the list L of the all unresolved nodes (nonterminal symbols ready for the expansion).
  #   2. Select only the nodes with the maximal depth from the list L and name it M.
  #   3. Select the first node N (and the corresponding nonterminal symbol S) of the list M.
  #   4. Take the codon of the genome and use it for selection of rule Alternative Mapper::RuleAlt of grammar[S]
  #   5. Expand the symbol S.
  #   6. Repeat from the step 1 until the termination condition (see Mapper::Base) is met.
  #   
  # See 
  # https://eprints.kfupm.edu.sa/43213/1/43213.pdf 
  #   
  class DepthFirst < Generator
    include LocusFirst
    include ExtendAll #behavior same as ExtendDepth, but simpler
    include ConstantsNoSupport
  end

  # Mapper class employing the breath-first node expansion strategy:
  #   1. Create the list L of the all unresolved nodes (nonterminal symbols ready for the expansion).
  #   2. Select only the nodes with the minimal depth from the list L and name it M.
  #   3. Select the first node N (and the corresponding nonterminal symbol S) of the list M.
  #   4. Take the codon of the genome and use it for selection of rule Alternative Mapper::RuleAlt of grammar[S]
  #   5. Expand the symbol S.
  #   6. Repeat from the step 1 until the termination condition (see Mapper::Base) is met.
  #   
  class BreadthFirst < Generator
    include LocusFirst
    include ExtendBreadth
    include ConstantsNoSupport   
  end

###

  # Mapper class employing the depth-locus node expansion strategy:
  #   1. Create the list L of the all unresolved nodes (nonterminal symbols ready for the expansion).
  #   2. Select only the nodes with the maximal depth from the list L and name it M.
  #   3. Take the locus codon and use it as the index i on the list M.
  #   4. Select the node N=M[i] from the list M (and the corresponding nonterminal symbol S).
  #   5. Take the subsequent (allele) codon of the genome and use it for selection of rule Alternative Mapper::RuleAlt of grammar[S]
  #   6. Expand the symbol S. 
  #   7. Repeat from the step 1 until the termination condition (see Mapper::Base) is met.
  #   
  # See 
  # http://ncra.ucd.ie/papers/pigegecco2004.pdf
  #  
  class DepthLocus < Generator
    include LocusGenetic
    include ExtendDepth
    include ConstantsNoSupport   
  end

  # Mapper class employing the depth-locus node expansion strategy with embedded constants support.
  # 
  # Embedded constants simplify derivation trees during genotype-phenotype mapping phase which may help to a search algorithm by reducing a search space.
  # Constants' values are stored directly in the genotype in one or mode codons. Their encoding is specified in the configuration of DepthLocusEmbConsts mapper
  # under the "embedded_constants" section. Identifiers of constants have to _exactly_ match with the literals (placeholder) used the grammar. 
  # Ranges of constants have to be specified in the configuration, number of codons used for constant encoding need not to be specified (default is 1).
  # The type of the constant (Float or Integer) is inferred from the types of range limits.
  # 
  # Example configuration:
  #
  #   mapper:
  #     class: DepthLocusEmbConsts
  #     embedded_constants:
  #       const1:
  #         min: -2.0
  #         max: 2.0
  #       C2:
  #         codons: 2
  #         min: 0
  #         max: 80000
  #
  # For instance, given the configuration above, each occurence of the terminal symbol "C2" is replaced by the random integer constant during the phenotype initialization.
  #
  # For details see:
  # http://dl.acm.org/citation.cfm?id=2001966 
  #
  # The expansion strategy is described in Mapper::DepthLocus.
  #
  class DepthLocusEmbConsts < Generator
    include LocusGenetic
    include ExtendAll #behavior same as ExtendDepth, but simpler
    include ConstantsInGenotype
  end
 
  # Mapper class employing the breadth-locus node expansion strategy:
  #   1. Create the list L of the all unresolved nodes (nonterminal symbols ready for the expansion).
  #   2. Select only the nodes with the minimal depth from the list L and name it M.
  #   3. Take the locus codon and use it as the index i on the list M.
  #   4. Select the node N=M[i] from the list M (and the corresponding nonterminal symbol S).
  #   5. Take the subsequent (allele) codon of the genome and use it for selection of rule Alternative Mapper::RuleAlt of grammar[S]
  #   6. Expand the symbol S.   
  #   7. Repeat from the step 1 until the termination condition (see Mapper::Base) is met.
  #   
  # See 
  # http://ncra.ucd.ie/papers/pigegecco2004.pdf
  #  
  class BreadthLocus < Generator
    include LocusGenetic
    include ExtendBreadth
    include ConstantsNoSupport   
  end

  # Mapper class employing the all-locus node expansion strategy:
  #   1. Create the list L of the all unresolved nodes (nonterminal symbols ready for the expansion).
  #   2. Take the locus codon and use it as the index i on the list L.
  #   3. Select the node N=L[i] from the list L (and the corresponding nonterminal symbol S).
  #   4. Take the subsequent (allele) codon of the genome and use it for selection of rule Alternative Mapper::RuleAlt of grammar[S]
  #   5. Expand the symbol S.   
  #   6. Repeat from the step 1 until the termination condition (see Mapper::Base) is met.
  #   
  class AllLocus < Generator
    include LocusGenetic
    include ExtendAll
    include ConstantsNoSupport   
  end
 
end # Mapper

