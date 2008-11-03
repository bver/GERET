
#
# class Mapping holds the genotype-phenotype mapping configuration. 
# Currently it consists of these items:
#
# codon_style - defines meaning of the codon values. Supported values are 
# :rule (a single value) and :rule_locus (a pair)
#
# bucket_rule - whether the rule value has an intrinsic polymorphism (false) or 
# distinct values using bucket rule (true) 
#
# max_rule - maximal number of rule value (useful only when bucket_rule=true)
#
# max_locus - maximal number of locus values
#
# max_wrappings - maximal allowed number of wrappings over the end of chromosome
#
# overrun - determines what happens when  maximal allowed number of wrappings was done.
# possible values are :fail (no phenotype is created) 
# or :fading_0 (all rule and/or locus values are zeroed - requires non-recursive rules with index 0)
#
class Mapping < Struct.new( :codon_style, :bucket_rule, :max_rule, :max_locus, :max_wrappings, :overrun )

  def initialize *args
    super
    self.codon_style = :rule if self.codon_style.nil?
    self.bucket_rule = false if self.bucket_rule.nil?
    self.max_rule = 255 if self.max_rule.nil?
    self. max_locus = 255 if self.max_locus.nil?
    self.max_wrappings = 10 if self.max_wrappings.nil?
    self.overrun = :fail if self.overrun.nil?
  end

end
