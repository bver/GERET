#!/usr/bin/ruby

require 'test/unit'
require 'lib/abnf_tokenizer'

class TC_Mapping < Test::Unit::TestCase

  def setup
    @example1 = <<ABNF_TEXT
;start symbol
start-symbol = foo [bar] (foo2 bar)

foo          = 1*4DIGIT / 1*VCHAR / 5DIGIT ["-" *4DIGIT]
foo          =/ 1*8(DIGIT / ALPHA) CR LF ; some comment

   ;comment
bar = %d13.10 %x0D / %x30-37
bar /= HEXDIG DQUOTE HTAB WSP LWSP CHAR OCTET CTL CRLF BIT

foo2 = 3SP / *4CHAR
ABNF_TEXT
  end

end

