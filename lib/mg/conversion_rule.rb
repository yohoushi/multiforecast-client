# -*- encoding: utf-8 -*-

module Mg
  module ConversionRule
    def service_name(path = nil)
      'mgclient'
    end

    def section_name(path = nil)
      'mgclient'
    end

    def graph_name(path)
      CGI.escape(path)
    end

    def path(service_name, section_name, graph_name)
      CGI.unescape(graph_name)
    end

    def id(path, num_instances)
      # ToDo (complex graph ...)
      path.bytes.inject(:+) % num_instances
    end
  end
end
