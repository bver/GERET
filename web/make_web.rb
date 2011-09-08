
# gem instal rdoc
# gem install RedCloth
# emerge graphviz

#require 'auto_gem'
require 'redcloth'
Geret = '../'

system "rm -rf web/"
system "mkdir web/"

template = IO.read 'template.html'
index = RedCloth.new( IO.read( Geret + 'README.textile' ) ).to_html
File.open( 'web/index.html', 'w' ) { |f| f.puts template.gsub(/#CONTENT#/, index) }

system "yardoc --title=GERET --files='#{Geret}/lib/*.rb' --output-dir=web/ #{Geret}/lib/ #{Geret}/algorithm/ #{Geret}/algorithm/support/"

system "cp style.css doc.html web/"

