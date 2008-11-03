
class Mapping < Struct.new( :codon_style, :bucket_rule, :max_rule, :max_locus, :max_wrappings, :overrun )

  def initialize *args
    super *args
    self.codon_style = :rule if self.codon_style.nil?
    self.bucket_rule = false if self.bucket_rule.nil?
    self.max_rule = 255 if self.max_rule.nil?
    self. max_locus = 255 if self.max_locus.nil?
    self.max_wrappings = 10 if self.max_wrappings.nil?
    self.overrun = :fail if self.overrun.nil?
  end

end
