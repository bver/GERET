
class Report < Hash

  def initialize
    super
    @steps = 0
    @line = ''
    self.default = []
  end

  attr_reader :steps

  def << line
    @line = line + "\n" 
  end

  def [] label
    store( label, [] ) unless has_key? label
    fetch(label)
  end

  def next
    @steps += 1
   
    each_value do |ary|
      raise "Report: cannot record twice in a single step" if ary.size > @steps
      ary.push nil while ary.size < @steps
    end
  end

  def labels
    keys.sort {|a,b| a.to_s <=> b.to_s }
  end

end

class ReportText < Report

  def output
    out = @line
    labels.each do |label|
      value = self[label].last
      next if value.nil?
      out += "#{label}: #{value}\n"
    end
    out
  end

end

