#require 'net/http'


class Articles < Application
  # provides :xml, :yaml, :js

  @@piped = IO.popen( 'double.rb', 'r+' )

  def index
    ### @articles = Article.all
    ### display @articles

    @hello =  'Hello world!'

    parsedURI = URI.parse('http://naspirale.cz/robots.txt')
    res = Net::HTTP.get_response( parsedURI )
    @hello = res.body

    @@piped.puts("this", "is", "a", "test")
    5.times { @hello += @@piped.readline }

    display @hello
  end
...




  cat /usr/local/bin/double.rb
#!/usr/bin/ruby

$stdin.each_line do |line|
  puts line
  puts line
  $stdout.flush
end

