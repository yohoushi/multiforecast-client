# -*- encoding: utf-8 -*-
require 'cgi'

module MultiForecast
  module ConversionRule
    def service_name(path = nil)
      'mgclient'
    end

    def section_name(path = nil)
      # + => '%20' is to avoid GF (Kossy?) bug
      CGI.escape(File.dirname(path)).gsub('+', '%20')
    end

    def graph_name(path)
      File.basename(path)
    end

    def path(service_name, section_name, graph_name)
      dirname = CGI.unescape(section_name.gsub('%20', '+'))
      basename = graph_name
      dirname == "." ? basename : "#{dirname}/#{basename}"
    end

    def id(path)
      @rules.each do |dir, id|
        return id if path.index(dir) == 0
      end
      return 0
    end

    def ids(path)
      @rules.each_with_object([]) do |(dir, id), ids|
        ids << id if path.index(dir) == 0
      end
    end
  end
end
