
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
  #   See https://eprints.kfupm.edu.sa/43213/1/43213.pdf 
  #   
  class DepthFirst < Generator
    include LocusFirst
    include ExtendAll #behavior same as ExtendDepth, but simpler
    include PolyIntrinsic 
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
    include PolyIntrinsic 
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
  #  See http://ncra.ucd.ie/papers/pigegecco2004.pdf
  #  
  class DepthLocus < Generator
    include LocusGenetic
    include ExtendDepth
    include PolyIntrinsic 
  end

  # Mapper class employing the depth-locus node expansion strategy:
  #   1. Create the list L of the all unresolved nodes (nonterminal symbols ready for the expansion).
  #   2. Select only the nodes with the minimal depth from the list L and name it M.
  #   3. Take the locus codon and use it as the index i on the list M.
  #   4. Select the node N=M[i] from the list M (and the corresponding nonterminal symbol S).
  #   5. Take the subsequent (allele) codon of the genome and use it for selection of rule Alternative Mapper::RuleAlt of grammar[S]
  #   6. Expand the symbol S.   
  #   7. Repeat from the step 1 until the termination condition (see Mapper::Base) is met.
  #   
  #  See http://ncra.ucd.ie/papers/pigegecco2004.pdf
  #  
  class BreadthLocus < Generator
    include LocusGenetic
    include ExtendBreadth
    include PolyIntrinsic 
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
    include PolyIntrinsic 
  end
 
###

  # Mapper class employing the depth-bucket node expansion strategy:
  #   1. Create the list L of the all unresolved nodes (nonterminal symbols ready for the expansion).
  #   2. Select only the nodes with the maximal depth from the list L and name it M.
  #   3. Select the first node N (and the corresponding nonterminal symbol S) of the list M.
  #   4. Take the codon of the genome and use the "bucket rule" for computation of the index i. 
  #   5. Use it for selection of i-th rule Alternative Mapper::RuleAlt of grammar[S]
  #   6. Expand the symbol S.
  #   7. Repeat from the step 1 until the termination condition (see Mapper::Base) is met.
  #   
  # See http://books.google.com/books?hl=en&lr=&id=eCbu4GwRLusC&oi=fnd&pg=PA123&ots=hUc3zvqYIh&sig=xKuVudQQ8GIolgdPzcoyOWRpdn8 
  # 
  class DepthBucket < Generator
    include LocusFirst
    include ExtendAll #behavior same as ExtendDepth, but simpler
    include PolyBucket 
  end

  # Mapper class employing the breath-bucket node expansion strategy:
  #   1. Create the list L of the all unresolved nodes (nonterminal symbols ready for the expansion).
  #   2. Select only the nodes with the minimal depth from the list L and name it M.
  #   3. Select the first node N (and the corresponding nonterminal symbol S) of the list M.
  #   4. Take the codon of the genome and use the "bucket rule" for computation of the index i. 
  #   5. Use it for selection of i-th rule Alternative Mapper::RuleAlt of grammar[S]
  #   6. Expand the symbol S.
  #   7. Repeat from the step 1 until the termination condition (see Mapper::Base) is met.
  #   
  # See http://books.google.com/books?hl=en&lr=&id=eCbu4GwRLusC&oi=fnd&pg=PA123&ots=hUc3zvqYIh&sig=xKuVudQQ8GIolgdPzcoyOWRpdn8 
  #   
  class BreadthBucket < Generator
    include LocusFirst
    include ExtendBreadth
    include PolyBucket 
  end
 
end # Mapper
