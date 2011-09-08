
$LOAD_PATH << '.'

require 'test/unit'
require 'lib/report'

include Util

class FileMock
  attr_reader :content
  
  def initialize
    @content = ''
  end

  def puts text
    @content += "#{text}\n"
  end

  def print text
    @content += text.to_s
  end
end

class TC_Report < Test::Unit::TestCase

  def test_basic
    r = Report.new
    assert_equal( 0, r.steps )

    r[:maxfitness] << 42
    r[:diversity] << 12
    r[:coolness] << 'ok'
    assert_equal( 0, r.steps )   
    r.next
    assert_equal( 1, r.steps )

    r[:maxfitness] << 34
    r[:coolness] << 'nope'
    r.next
    assert_equal( 2, r.steps )

    r[:diversity] << 22
    r[:coolness] << 'ok'
    r.next

    assert_equal( 3, r.steps )
    assert_equal( ['ok', 'nope', 'ok'], r[:coolness] )
    assert_equal( [12, nil, 22], r[:diversity] )
    assert_equal( [42, 34, nil], r[:maxfitness] )   
  
    assert_equal( [:coolness, :diversity, :maxfitness], r.labels )
  end

  def test_twicepush
    r = Report.new
    assert_equal( 0, r.steps )

    r[:maxfitness] << 42
    r[:maxfitness] << 4888   
  
    exception = assert_raise( RuntimeError ) { r.next }
    assert_equal( "Report: cannot record twice in a single step", exception.message )
  end

  def test_output
    r = ReportText.new

    r[:maxfitness] << 42
    r[:diversity] << 12
    r[:coolness] << 'ok'
    r.next

    r[:maxfitness] << 34
    r[:coolness] << 'nope'
    r.next

    out = <<OUTPUT
coolness: nope
maxfitness: 34
OUTPUT

    assert_equal( out, r.output )
  end

  def test_line
    r = ReportText.new

    r << "this line is omitted"
    r << "and this line too"
    r[:coolness] << 'ok'
    r.next

    r[:coolness] << 'nope'
    r << "this line is displayed"
    r << "this line is also displayed"
    r.next

    out = <<OUTPUT
this line is displayed
this line is also displayed
coolness: nope
OUTPUT

    assert_equal( out, r.output )
  end
 
  def test_stream_report
    fm = FileMock.new    
    r = ReportStream.new fm

    r << 'line1'
    r[:maxfitness] << 42
    r[:diversity] << 12
    r[:coolness] << 'ok'
    r.next

    r << 'line2'   
    r[:maxfitness] << 34
    r[:coolness] << 'nope'
    r.next

    out = <<OUTPUT2
line1
maxfitness: 42
diversity: 12
coolness: ok
line2
maxfitness: 34
coolness: nope
OUTPUT2
   
    assert_equal( out, fm.content )
    assert_equal( '', r.output )   
  end

end

