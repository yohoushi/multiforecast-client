# -*- encoding: utf-8 -*-
require 'growthforecast-client'

module Mg
  class Error < StandardError; end
  class NotFound < Error; end
  class AlreadyExists < Error; end

  class Client
    include ::Mg::ConversionRule
    attr_accessor :clients
    attr_accessor :debug

    # @param [String] base_uri The base uri of GrowthForecast
    def initialize(base_uris = ['http://locahost:5125'])
      base_uris = base_uris.kind_of?(Array) ? base_uris : [base_uris]
      @clients = []
      base_uris.each do |base_uri|
        @clients << GrowthForecast::Client.new(base_uri)
      end
      @num_instances = base_uris.size
    end

    def debug=(flag)
      @debug = flag
      @clients.each {|c| c.debug = flag }
    end

    def client(path)
      @last_client = @clients[id(path, @num_instances)]
    end

    def last_client
      @last_client
    end

    def last_response
      @last_client.last_response
    end

    # GET the JSON API
    # @param [String] path
    # @return [Hash] response body
    def get_json(path)
      client(path).get_json(path)
    end

    # POST the JSON API
    # @param [String] path
    # @param [Hash] data 
    # @return [Hash] response body
    def post_json(path, data = {})
      client(path).post_json(path, data)
    end

    # POST the non-JSON API
    # @param [String] path
    # @param [Hash] data 
    # @return [String] response body
    def post_query(path, data = {})
      client(path).post_query(path, data)
    end

    # Get the list of graphs, /json/list/graph
    # @return [Hash] list of graphs
    # @example
    # [
    #   {"gfuri"=>"xxxxx",
    #    "service_name"=>"mbclient",
    #    "section_name"=>"mbclient",
    #    "graph_name"=>"test%2Fhostname%2F%3C2sec_count",
    #    "path"=>"test/hostname/<2sec_count",
    #    "id"=>4},
    #   {"gfuri"=>"xxxxx",
    #    "service_name"=>"mbclient",
    #    "section_name"=>"mbclient",
    #    "graph_name"=>"test%2Fhostname%2F%3C1sec_count",
    #    "path"=>"test/hostname/<1sec_count",
    #    "id"=>3},
    # ]
    def list_graph
      clients.inject([]) do |ret, client|
        graphs = client.list_graph(service_name).each do |graph|
          graph['gfuri'] = client.base_uri
          graph['path']  = path(graph['service_name'], graph['section_name'], graph['graph_name'])
        end
        ret = ret + graphs
      end
    end

    # Get the propety of a graph, GET /api/:path
    # @param [String] path
    # @return [Hash] the graph property
    # @example
    #{
    #  "gfuri" => "xxxxxx",
    #  "path" => "test/hostname/<4sec_count",
    #  "service_name"=>"mbclient",
    #  "section_name"=>"mbclient",
    #  "graph_name"=>"test%2Fhostname%2F%3C4sec_count",
    #  "number"=>1,
    #  "llimit"=>-1000000000,
    #  "mode"=>"gauge",
    #  "stype"=>"AREA",
    #  "adjustval"=>"1",
    #  "meta"=>"",
    #  "gmode"=>"gauge",
    #  "color"=>"#cc6633",
    #  "created_at"=>"2013/02/02 00:41:11",
    #  "ulimit"=>1000000000,
    #  "id"=>21,
    #  "description"=>"",
    #  "sulimit"=>100000,
    #  "unit"=>"",
    #  "sort"=>0,
    #  "updated_at"=>"2013/02/02 02:32:10",
    #  "adjust"=>"*",
    #  "type"=>"AREA",
    #  "sllimit"=>-100000,
    #  "md5"=>"3c59dc048e8850243be8079a5c74d079"}
    def get_graph(path)
      client(path).get_graph(service_name(path), section_name(path), graph_name(path)).tap do |graph|
        graph['gfuri'] = client(path).base_uri
        graph['path']  = path
      end
    end

    # Post parameters to a graph, POST /api/:path
    # @param [String] path
    # @param [Hash] params The POST parameters. See #get_graph
    def post_graph(path, params)
      client(path).post_graph(service_name(path), section_name(path), graph_name(path), params)
    end

    # Delete a graph, POST /delete/:path
    # @param [String] path
    def delete_graph(path)
      client(path).delete_graph(service_name(path), section_name(path), graph_name(path))
    end

    # Update the property of a graph, /json/edit/graph/:id
    # @param [String] path
    # @param [Hash]   params
    #   All of parameters given by #get_graph are available except `number` and `mode`.
    # @return [Hash]  error response
    # @example
    # {"error"=>0} #=> Success
    # {"error"=>1} #=> Error
    def edit_graph(path, params)
      client(path).edit_graph(service_name(path), section_name(path), graph_name(path), params)
    end

    # Get the list of complex graphs, /json/list/complex
    # @return [Hash] list of complex graphs
    # @example
    # [
    #   {"gfuri"=>"xxxxx",
    #    "path"=>"test/hostname/<2sec_count",
    #    "service_name"=>"mbclient",
    #    "section_name"=>"mbclient",
    #    "graph_name"=>"test%2Fhostname%2F%3C2sec_count",
    #    "id"=>4},
    #   {"gfuri"=>"xxxxx",
    #    "path"=>"test/hostname/<1sec_count",
    #    "service_name"=>"mbclient",
    #    "section_name"=>"mbclient",
    #    "graph_name"=>"test%2Fhostname%2F%3C1sec_count",
    #    "id"=>3},
    # ]
    def list_complex
      clients.inject([]) do |ret, client|
        graphs = client.list_complex(service_name).each do |graph|
          graph['gfuri'] = client.base_uri
          graph['path']  = path(graph['service_name'], graph['section_name'], graph['graph_name'])
        end
        ret = ret + graphs
      end
    end

    # Create a complex graph
    #
    # @param [Array] from_graphs Array of graph properties whose keys are
    #   ["path", "gmode", "stack", "type"]
    # @param [Hash] to_complex Property of Complex Graph, whose keys are like
    #   ["path", "description", "sort"]
    def create_complex(from_graphs, to_complex)
      from_graphs = from_graphs.dup
      to_complex = to_complex.dup

      from_graphs.each do |from_graph|
        from_graph['service_name'] = service_name(from_graph['path'])
        from_graph['section_name'] = section_name(from_graph['path'])
        from_graph['graph_name']   = graph_name(from_graph['path'])
        from_graph.delete('path')
        from_graph.delete('gfuri')
      end

      to_complex['service_name'] = service_name(to_complex['path'])
      to_complex['section_name'] = section_name(to_complex['path'])
      to_complex['graph_name']   = graph_name(to_complex['path'])
      path = to_complex.delete('path')

      # NOTE: FROM_GRAPHS AND TO _COMPLEX MUST BE THE SAME GF SERVER
      client(path).create_complex(from_graphs, to_complex)
    end

    # Get a complex graph
    #
    # @param [String] path
    # @return [Hash] the graph property
    # @example
    # {"number"=>0,
    #  "complex"=>true,
    #  "created_at"=>"2013/05/20 15:08:28",
    #  "service_name"=>"app name",
    #  "section_name"=>"host name",
    #  "id"=>18,
    #  "graph_name"=>"complex graph test",
    #  "data"=>
    #   [{"gmode"=>"gauge", "stack"=>false, "type"=>"AREA", "graph_id"=>218},
    #    {"gmode"=>"gauge", "stack"=>true, "type"=>"AREA", "graph_id"=>217}],
    #  "sumup"=>false,
    #  "description"=>"complex graph test",
    #  "sort"=>10,
    #  "updated_at"=>"2013/05/20 15:08:28"}
    def get_complex(path)
      client(path).get_complex(service_name(path), section_name(path), graph_name(path)).tap do |graph|
        graph['gfuri'] = client(path).base_uri
        graph['path']  = path
      end
    end

    # Delete a complex graph
    #
    # @param [String] path
    # @return [Hash]  error response
    # @example
    # {"error"=>0} #=> Success
    # {"error"=>1} #=> Error
    def delete_complex(path)
      client(path).delete_complex(service_name(path), section_name(path), graph_name(path))
    end

    # Get graph image uri
    #
    # @param [String] path
    # @return [Hash]  error response
    # @example
    def get_graph_uri(path, unit = 'h')
      "#{client(path).base_uri}/graph/#{service_name(path)}/#{section_name(path)}/#{graph_name(path)}?t=#{unit}"
    end

    # Get complex graph image uri
    #
    # @param [String] path
    # @return [Hash]  error response
    # @example
    def get_complex_uri(path, unit = 'h')
      "#{client(path).base_uri}/complex/graph/#{service_name(path)}/#{section_name(path)}/#{graph_name(path)}?t=#{unit}"
    end
  end
end

