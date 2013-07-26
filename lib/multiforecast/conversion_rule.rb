# -*- encoding: utf-8 -*-
require 'cgi'

module MultiForecast
  module ConversionRule
    def uri_escape(string)
      # + => '%20' is to avoid GF (Kossy?) bug
      # . => '%2E' because a/./b is recognized as a/b as URL
      CGI.escape(string).gsub('+', '%20').gsub('.', '%2E') if string
    end

    def uri_unescape(string)
      CGI.unescape(string) if string
    end

    def lstrip(string, substring)
      string.index(substring) == 0 ? string[substring.size..-1] : string
    end

    def service_name(path)
      path = lstrip(path, '/')
      return path.split('/')[0] if path.count('/') == 2
      'multiforecast'
    end

    def section_name(path)
      path = lstrip(path, '/')
      return path.split('/')[1] if path.count('/') == 2
      uri_escape(File.dirname(path))
    end

    def graph_name(path)
      path = lstrip(path, '/')
      File.basename(path)
    end

    def path(service_name, section_name, graph_name)
      return "#{service_name}/#{section_name}/#{graph_name}" unless service_name == "multiforecast"
      dirname = uri_unescape(section_name)
      basename = graph_name
      dirname == "." ? basename : "#{dirname}/#{basename}"
    end

    def id(path)
      path = lstrip(path, '/')
      @mapping.each do |base_path, base_uri|
        return base_path if path.index(base_path) == 0
      end
      return @mapping.keys.first
    end

    def ids(path)
      path = lstrip(path, '/')
      @mapping.map do |base_path, base_uri|
        base_path if path.index(base_path) == 0
      end.compact
    end
  end
end
