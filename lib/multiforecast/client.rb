# -*- encoding: utf-8 -*-
require 'growthforecast-client'

module MultiForecast
  class Error < StandardError; end
  class NotFound < Error; end
  class AlreadyExists < Error; end

  class Client
    include ::MultiForecast::ConversionRule
    attr_accessor :clients
    attr_accessor :debug_dev
    attr_accessor :short_metrics

    # @param [Hash] opts
    #   [Hash] mapping: Mapping rules from `path` to GrowthForecast's `base_uri`.
    def initialize(opts = {})
      @mapping = {}
      mapping = opts['mapping'] || { '' => 'http://localhost:5125' }
      # remove heading / of path
      mapping.each {|key, val| @mapping[lstrip(key, '/')] = val }
      @short_metrics = opts['short_metrics'] || true

      @clients = {}
      @base_uris = {}
      @mapping.each do |path, base_uri|
        if base_uri.kind_of?(Hash)
          base_uri = uri['in_uri']
          out_uri  = uri['out_uri']
        end
        @clients[path] = GrowthForecast::Client.new(base_uri)
        @base_uris[path] = out_uri || base_uri
      end
    end

    # set the `debug_dev` attribute of HTTPClient
    # @param [IO] debug_dev such as STDOUT
    def debug_dev=(debug_dev)
      @debug_dev = debug_dev
      @clients.each {|c| c.debug_dev = debug_dev }
    end

    def clients(base_path = nil)
      base_path.nil? ? @clients.values : @clients.values_at(*ids(base_path)).compact
    end

    def client(path)
      @last_client = @clients[id(path)]
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
    # @param [String] base_path
    # @param [Regexp] regexp list only matched graphs
    # @return [Hash] list of graphs
    # @example
    # [
    #   {"base_uri"=>"xxxxx",
    #    "service_name"=>"mbclient",
    #    "section_name"=>"mbclient",
    #    "graph_name"=>"test%2Fhostname%2F%3C2sec_count",
    #    "path"=>"test/hostname/<2sec_count",
    #    "id"=>4},
    #   {"base_uri"=>"xxxxx",
    #    "service_name"=>"mbclient",
    #    "section_name"=>"mbclient",
    #    "graph_name"=>"test%2Fhostname%2F%3C1sec_count",
    #    "path"=>"test/hostname/<1sec_count",
    #    "id"=>3},
    # ]
    def list_graph(base_path = nil, regexp = nil)
      clients(base_path).inject([]) do |ret, client|
        graphs = []
        client.list_graph.each do |graph|
          graph['base_uri'] = client.base_uri
          graph['path']  = path(graph['service_name'], graph['section_name'], graph['graph_name'])
          if base_path.nil? or graph['path'].index(base_path) == 0
            graphs << graph if !regexp or regexp.match(graph['path'])
          end
        end
        ret = ret + graphs
      end
    end

    # Get the propety of a graph, GET /api/:path
    # @param [String] path
    # @return [Hash] the graph property
    # @example
    #{
    #  "base_uri" => "xxxxxx",
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
        graph['base_uri'] = client(path).base_uri
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
    # @param [String] base_path
    # @param [Regexp] regexp list only matched graphs
    # @return [Hash] list of complex graphs
    # @example
    # [
    #   {"base_uri"=>"xxxxx",
    #    "path"=>"test/hostname/<2sec_count",
    #    "service_name"=>"mbclient",
    #    "section_name"=>"mbclient",
    #    "graph_name"=>"test%2Fhostname%2F%3C2sec_count",
    #    "id"=>4},
    #   {"base_uri"=>"xxxxx",
    #    "path"=>"test/hostname/<1sec_count",
    #    "service_name"=>"mbclient",
    #    "section_name"=>"mbclient",
    #    "graph_name"=>"test%2Fhostname%2F%3C1sec_count",
    #    "id"=>3},
    # ]
    def list_complex(base_path = nil, regexp = nil)
      clients(base_path).inject([]) do |ret, client|
        graphs = []
        client.list_complex.each do |graph|
          graph['base_uri'] = client.base_uri
          graph['path']  = path(graph['service_name'], graph['section_name'], graph['graph_name'])
          if base_path.nil? or graph['path'].index(base_path) == 0
            graphs << graph if !regexp or regexp.match(graph['path'])
          end
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
        from_graph.delete('base_uri')
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
        graph['base_uri'] = client(path).base_uri
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
    # @param [Hash] params for the query string
    #   t      [String] the time unit such as 'h' (an hour), '4h' (4 hours), '8h', 'n' (half day), 'd' (a day), '3d', 'w', (a week), 'm' (a month), 'y' (a year).
    #                   Also, 'sh' 's4h' 's8h', 'sn', 'sd', 's3d' for graphs generated by short period GF worker.
    #                   Also, this parameter is overrided with 'c' or 'sc' when `from` parameter is set.
    #   from   [String|Time] the time period to show 'from'. String describing a time, or a Time object
    #   to     [String|Time] the time period to show 'to'.   String describing a time, or a Time Object
    #   width  [String] the widh of image to show
    #   height [String] the height of image to show
    # @return [Hash]  error response
    # @example
    def get_graph_uri(path, params = nil)
      params ||= {}
      params = preprocess_time_params(params) unless params.empty?
      "#{@base_uris[id(path)]}/graph/#{uri_escape(service_name(path))}/#{uri_escape(section_name(path))}/#{uri_escape(graph_name(path))}#{'?' unless params.empty?}#{query_string(params)}"
    end

    # Get complex graph image uri
    #
    # @param [String] path
    # @param [Hash] params for the query string
    #   t      [String] the time unit such as 'h' (an hour), '4h' (4 hours), '8h', 'n' (half day), 'd' (a day), '3d', 'w', (a week), 'm' (a month), 'y' (a year).
    #                   Also, 'sh' 's4h' 's8h', 'sn', 'sd', 's3d' for graphs generated by short period GF worker.
    #                   Also, this parameter is overrided with 'c' or 'sc' when `from` parameter is set.
    #   from   [String|Time] the time period to show 'from'. String describing a time, or a Time object
    #   to     [String|Time] the time period to show 'to'.   String describing a time, or a Time Object
    #   width  [String] the widh of image to show
    #   height [String] the height of image to show
    # @return [Hash]  error response
    # @example
    def get_complex_uri(path, params = nil)
      params ||= {}
      params = preprocess_time_params(params) unless params.empty?
      "#{@base_uris[id(path)]}/complex/graph/#{uri_escape(service_name(path))}/#{uri_escape(section_name(path))}/#{uri_escape(graph_name(path))}#{'?' unless params.empty?}#{query_string(params)}"
    end

    # process the time params (from and to)
    def preprocess_time_params(params)
      params = params.dup
      params['from'] = Time.parse(params['from']) if params['from'].kind_of?(String)
      params['to']   = Time.parse(params['to']) if params['to'].kind_of?(String)
      if params['from'] and params['to']
        # if from is more future than 3 days ago, use 'sc' (short period time worker)
        params['t']    = (@short_metrics && params['from'] > Time.now - 60 * 60 * 24 * 3) ? 'sc' : 'c'
        params['from'] = params['from'].strftime("%F %T %z") # format is determined
        params['to']   = params['to'].strftime("%F %T %z")
      end
      params
    end

    private

    # build URI query string
    #
    # @param [Hash] param
    # @return [String] query string
    # @example
    def query_string(params)
      return '' if params.nil?
      params.keys.collect{|key| "#{URI.escape(key.to_s)}=#{URI.escape(params[key].to_s)}" }.join('&')
    end
  end
end

