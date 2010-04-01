#!/usr/bin/ruby

require 'net/http'
require 'uri'

original = File.new("hudsonHawk.html", "r")
new = File.new("hudsonHawk.compiled.html", "w")

def fetch(uri_str, limit = 10)
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0
 
  puts "Fetching... " + uri_str
  response = Net::HTTP.get_response(URI.parse(uri_str))
  case response
    when Net::HTTPSuccess     then response.body
    when Net::HTTPRedirection then fetch(response['location'], limit - 1)
    else response.error!
  end
end

def css_fetch(base_href, filename) 
  puts "Found import: " + filename
  fetch(base_href + "/" + filename)
end

# No desire to buffer and consider performance right now.....
data = ""
original.each_line do |line| 
  data += line
end

data.gsub!(/<link .*href=['"]([^'"]+css)['"][^>]*>/) do |match|
  href = $1
  css = fetch(href)
  base_href = href.gsub(/(.*)\/[A-Za-z0-9.]*/) { $1 }
  while css.match("@import")
    puts "Substituting imports..."
    css.gsub!(/@import ['"]([^'"]+)['"];/) { css_fetch(base_href, $1) }
    css.gsub!(/@import url\(['"]([^'"]+)['"]\);/) { css_fetch(base_href, $1) }
    css.gsub!(/@import url\(['"]([^'"]+)['"]\);/) { css_fetch(base_href, $1) }
  end
  css.gsub!(/url\("([^")]+)"\)/) { "url('" + base_href + "/" + $1 + "')" }
  css.gsub!(/url\('([^')]+)'\)/) { "url('" + base_href + "/" + $1 + "')" }
  css.gsub!(/url\(([^')]+)\)/) { "url('" + base_href + "/" + $1 + "')" }
  "<style>" + css + "</style>"
end

data.gsub!(/<script .*src=['"]([^'"]+js)['"].*<\/script>/) do 
  href = $1
  puts "Found script: " + href
  js = fetch(href)
  "<script>" + js + "</script>"
end

puts "Writing..."
new.write(data)
new.flush

