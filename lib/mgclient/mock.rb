require 'mgclient' 
require 'mgclient/mock/setup.rb' 
require 'mgclient/mock/mock.rb'

def e(str)
  URI.escape(str) if str
end

def gfpath(path)
  URI.escape("#{service_name(path)}/#{section_name(path)}/#{graph_name(path)}")
end

def base_uri
  'http://localhost:5125'
end

def mgclient
  Mg::Client.new({dir: '', gfuri: base_uri})
end
