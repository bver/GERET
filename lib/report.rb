
module Util

# Reporting helper class. The Report instance provides the simple interface for reporting 
# the internal values and progression during the evolutionary algorithm's run.
# This class assumes the reporting is done in steps.
#
class Report < Hash

  # Prepare the empty reporter.
  def initialize
    super
    @steps = 0
    @line = ''
    @clear_line = true
    self.default = []
  end

  # The report step. This value is incremented by the Report#next.
  attr_reader :steps

  # Report the status (mostly textual) info for the current step. For example:
  #   r = ReportText.new 
  #   r << "this line is displayed"
  #   r << "this line is also displayed"
  #   r.next
  def << line
    @line = '' if @clear_line
    @clear_line = false
    @line += ( line + "\n" )
  end

  # Access the label for the current step. For instance:
  #   r['maxfitness'] << 42
  #   r['diversity'] << 12
  #   r['coolness'] << 'ok'
  #   r.next
  def [] label
    store( label, [] ) unless has_key? label
    fetch(label)
  end

  # Advance to the next step of the report.
  def next
    @steps += 1
    @clear_line = true  

    each_value do |ary|
      raise "Report: cannot record twice in a single step" if ary.size > @steps
      ary.push nil while ary.size < @steps
    end
  end

  # Return all labels used for reports, eg:
  #   r['maxfitness'] << 2122
  #   r['coolness'] << 'ok'
  #   r.next
  #   r['coolness'] << 'uh'  
  #   r['diversity'] << 12
  #   r.next
  #   r.labels # produces ['coolness', 'diversity', 'maxfitness']
  def labels
    keys.sort {|a,b| a.to_s <=> b.to_s }
  end

end

# The simplest possible Reporter's subclass.
# Suitable for commandline utilities.
class ReportText < Report

  # Return the text consisting of "label: value" formatted rows.
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

class ReportStream

  def initialize stream=$stdout
    @stream = stream
  end

  def << line
    @stream.puts line
  end
  
  def [] label 
    @stream.print "#{label}: "
    self
  end

  def next
  end

  def output
    ''
  end
  
end

end # Util

