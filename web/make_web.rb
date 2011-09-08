
# gem instal rdoc
# gem install RedCloth
# emerge graphviz

require 'auto_gem'
require 'redcloth'
Geret = '../'

system "rm -rf lib/ web/"
system "mkdir web/"

template = IO.read 'template.html'

index = RedCloth.new( IO.read( Geret + 'README.textile' ) ).to_html
File.open( 'web/index.html', 'w' ) { |f| f.puts template.gsub(/#CONTENT#/, index) }

system "cp -p -r #{Geret}/lib ."
system "cd lib/ && rdoc --diagram --inline-source --main geret.rb"
system "mv lib/doc/ web/"
system "rm -f web/doc/files/*~.html"
system "rm -rf lib/"
system "cp doc.html web/"

system "cp style.css web/"

