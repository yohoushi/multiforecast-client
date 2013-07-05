require 'multiforecast-client' 
require 'multiforecast/shared_context/setup.rb' 
require 'multiforecast/shared_context/mock.rb'

include MultiForecast::ConversionRule

def e(str)
  CGI.escape(str).gsub('+', '%20') if str
end

def gfpath(path)
  "#{e service_name(path)}/#{e section_name(path)}/#{e graph_name(path)}"
end

def base_uri
  'http://localhost:5125'
end

def mfclient(opts = {})
  opts[:rules] ||= { '' => base_uri }
  MultiForecast::Client.new(opts)
end
