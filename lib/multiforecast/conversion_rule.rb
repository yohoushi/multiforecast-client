# -*- encoding: utf-8 -*-
require 'cgi'

module MultiForecast
  module ConversionRule
    def service_name(path)
      return path.split('/')[0] if path.count('/') == 2
      'mfclient'
    end

    def section_name(path)
      return path.split('/')[1] if path.count('/') == 2
      # + => '%20' is to avoid GF (Kossy?) bug
      # . => '%2E' because a/./b is recognized as a/b as URL
      CGI.escape(File.dirname(path)).gsub('+', '%20').gsub('.', '%2E')
    end

    def graph_name(path)
      File.basename(path)
    end

    def path(service_name, section_name, graph_name)
      return "#{service_name}/#{section_name}/#{graph_name}" unless service_name == "mfclient"
      dirname = CGI.unescape(section_name)
      basename = graph_name
      dirname == "." ? basename : "#{dirname}/#{basename}"
    end

    def id(path)
      @mapping.each do |base_path, base_uri|
        return base_path if path.index(base_path) == 0
      end
      return @mapping.keys.first
    end

    def ids(path)
      @mapping.map do |base_path, base_uri|
        base_path if path.index(base_path) == 0
      end.compact
    end
  end
end
