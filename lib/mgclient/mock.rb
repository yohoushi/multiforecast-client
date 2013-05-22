require 'mgclient' 
require 'mgclient/mock/setup.rb' 
require 'mgclient/mock/mock.rb'

def e(str)
  CGI.escape(str).gsub('+', '%20') if str
end

def gfpath(path)
  "#{e service_name(path)}/#{e section_name(path)}/#{e graph_name(path)}"
end

def base_uri
  'http://localhost:5125'
end

def mgclient
  Mg::Client.new({dir: '', gfuri: base_uri})
end
