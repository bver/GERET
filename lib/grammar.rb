
module Mapper

  # The atomic part of the rule. 
  # If :type is :symbol, then :data means the string representing a nonterminal symbol.
  # If :type is :literal, then :data means the string representing terminal symbol(s).
  # The depth attribute is reserved for purposes of the mapper.
  # The :track is used only when Mapper#track_support_on == true 
  Token = Struct.new( :type, :data, :depth, :track )
  
  # The internal representation of the language syntax, used for the genotype->phenotype mapping of 
  # Grammatical Evolution. The genotype is basically the array of fixnums, the phenotype is the source
  # code in some programming language, or, in general, any construct following the syntax.  
  # See http://www.grammatical-evolution.org/ 
  # 
  # A Grammar instance is created by the parser (e.g. Abnf::Parser) and passed as a main constructor 
  # argument of objects subclassing Mapper::Base.
  # The instance of the Grammar class is basically a Hash of { symbol1 => Rule1, symbol2 => Rule2 ... } 
  # assignments. each_pair of the hash maps the nonterminal symbol[i] to RuleAlt[i]. The Mapper::RuleAlt 
  # object is the array of all rule alternatives expanding the given symbol).
  # 
  # The Grammar has to define a start_symbol for successful mapping. 
  # 
  class Grammar < Hash

    # Initialize a Grammar. 
    # The src argument is the instance of any Hash subclass (for deep copying), the start argument is 
    # the start symbol definition.
    def initialize( src=nil, start=nil )
      super()
      update src unless src.nil?

      if start.nil? 
        @start_symbol = src.start_symbol if src.kind_of? Grammar
      else
        @start_symbol = start
      end
    end

    # Return a deep copy of the instance.
    def deep_copy
      copy = Grammar.new( nil, @start_symbol )
      each_pair {|symb, alt| copy[symb] = alt.deep_copy }
      copy 
    end

    # Return the array of all defined the symbols, sorted.
    def symbols
      keys.sort
    end

    # Start symbol of the genotype-phenotype mapping.
    attr_accessor :start_symbol

  end

  # One rule alternative. Mapper::RuleAlt is, in fact, an array of Mapper::Token structures.
  # For instance:
  #   <expr> ::= X*Y  
  #   
  # defines the Mapper::Rule of one RuleAlt alternative for the symbol <expr>. 
  # The first and only RuleAlt consists of this sequence:
  #   Mapper::Token.new( :symbol, 'X' )
  #   Mapper::Token.new( :literal, '*' )
  #   Mapper::Token.new( :symbol, 'Y' ) 
  # 
  class RuleAlt < Array

    # Initialize the array of the rules.
    # The src argument is the instance of an array of Mapper::Token instances. 
    # The recursive argument will be copied into self.recursivity attribute.
    # The arity argument will be copied into self.arity attribute. 
    # The min_depth will be copied into self.min_depth attribute.
    def initialize( ary=nil, recursive=nil, arity=nil, min_depth=nil )
      super ary unless ary.nil? 
      @recursivity = recursive
      @arity = arity
      @min_depth = min_depth
    end 

    # Return a deep copy of the instance.   
    def deep_copy
      alt = map {|t| Token.new( t.type, t.data, t.depth ) } 
      RuleAlt.new( alt, @recursivity, @arity, @min_depth )
    end

    # The RuleAlt recursivity used in Validator.analyze_recursivity process (see), based on nonterminal :symbol-ic Token-s.
    # Allowed values are: 
    #   :infinite ... the RuleAlt contains at least one :infinite :symbol, 
    #   :cyclic ... the RuleAlt contains no :infinite symbol and contains at least one :cyclic :symbol, 
    #   :terminating .. the RuleAlt does not contain :infinite nor :cyclic :symbol-s (ie. contains only :literal-s). 
    #   
    attr_accessor :recursivity

    # The RuleAlt arity used in Validator.analyze_arity process (see). 
    # 'arity' is the number of tokens with type == :symbol in the RuleAlt 
    attr_accessor :arity

    #  The RuleAlt min_depth used in Validator.analyze_min_depth process (see).
    #  This is a minimal number of mapping steps required by the generator to finish the mapping process.
    attr_accessor :min_depth

  end
 
  # Right-hand side of the syntactic rule, composed from logical aternatives.
  # Rule contains one or more Mapper::RuleAlt objects, for GE Mapper::Base to select from.
  #
  # For instance:
  #   <expr> ::= X | X+Y | X*Y  
  #   
  # defines the Rule of three RuleAlts for the symbol "<expr>". 
  # 
  class Rule < Array
    
    # Initialize the Rule from the ary argument (ie. from the Enumerable of RuleAlts).
    # The recursive, sn_altering and min_depth arguments will be copied into self.recursivity, 
    # self.sn_altering and self.min_depth attribute, respectively. 
    #  
    def initialize( ary=nil, recursive=nil, sn_altering=nil, min_depth=nil )
      super ary unless ary.nil?
      @recursivity = recursive
      @sn_altering = sn_altering
      @min_depth = min_depth     
    end 

    # Return a deep copy of the instance.     
    def deep_copy
      rule = map {|r| r.deep_copy } 
      Rule.new( rule, @recursivity, @sn_altering, @min_depth )
    end

    # The Rule (symbol) recursivity used in Validator.analyze_min_depth process (see).
    # Allowed values are: 
    #   :infinite ... the Rule contains only :infinite RuleAlts, 
    #   :cyclic ... the Rule contains at least one :cyclic RuleAlt, 
    #   :terminating .. the Rule contains only :terminating RuleAlts. 
    #   
    attr_accessor :recursivity   

    # The sn_altering (structural/nodal altering) attribute is used in Validator.analyze_sn_altering process (see).
    # Allowed values are:
    #   :structural ... the mutation on this position can result in the structural change of the phenotype.
    #   :nodal ... the mutation on this position cannot result in the structural change (the decision tree is unchanged).
    #
    attr_accessor :sn_altering

    #  The min_depth attribute used in Validator.analyze_recursivity process (see).
    #  This is a minimal number of mapping steps required by the generator to finish the mapping process.
    attr_accessor :min_depth
   
  end

end

