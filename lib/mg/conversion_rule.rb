# -*- encoding: utf-8 -*-
require 'cgi'

module Mg
  module ConversionRule
    def service_name(path = nil)
      'mgclient'
    end

    def section_name(path = nil)
      'mgclient'
    end

    def graph_name(path)
      ::CGI.escape(path)
    end

    def path(service_name, section_name, graph_name)
      ::CGI.unescape(graph_name)
    end

    def id(path)
      @rules.each do |regexp, id|
        return id if path =~ regexp
      end
      return 0
    end

    def ids(path)
      @rules.each_with_object([]) do |(regexp, id), ids|
        ids << id if path =~ regexp
      end
    end
  end
end
