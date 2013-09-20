# -*- encoding: utf-8 -*-
require 'thor'
require 'yaml'
require 'multiforecast-client'

class MultiForecast::CLI < Thor
  include ::MultiForecast::ConversionRule
  class_option :config,    :aliases => ["-c"], :type => :string
  class_option :silent,    :aliases => ["-S"], :type => :boolean

  def initialize(args = [], opts = [], config = {})
    super(args, opts, config)

    if options['config'] && File.exists?(options['config'])
      @options = YAML.load_file(options['config']).merge(@options)
    end
    @client = MultiForecast::Client.new(@options)
  end

  desc 'generate config', 'Generate a sample config file'
  def generate(target)
    config = {
      'mapping' => { '' => 'http://localhost:5125' },
    }
    File.open("multiforecast.yml", "w") do |file|
      YAML.dump(config, file)
      $stdout.puts "Generated #{file.path}"
    end
  end

  desc 'post <json> <path>', 'Post a parameter to a path'
  long_desc <<-LONGDESC
    Post a parameter to a path

    ex) multiforecast post '{"number":0}' 'test/test' -c multiforecast.yml
  LONGDESC
  def post(json, path)
    path = lstrip(path, '/')
    exec do
      res = @client.post_graph(path, JSON.parse(json))
      $stdout.puts res unless @options['silent']
    end
  end

  # NOTE: base_path argument should be a requirement for foolproof
  desc 'delete <base_path>', 'Delete a graph or graphs under a path'
  long_desc <<-LONGDESC
    Delete a graph or graphs under a path

    ex) multiforecast delete 'test/test' -c multiforecast.yml
  LONGDESC
  option :graph_names,   :type => :array, :aliases => '-g'
  def delete(base_path)
    graph_names = options['graph_names']
    base_path = lstrip(base_path, '/')

    graphs = @client.list_graph(base_path)
    delete_graphs(graphs, graph_names)

    complexes = @client.list_complex(base_path)
    delete_complexes(complexes, graph_names)
    $stderr.puts "Not found" if graphs.empty? and complexes.empty? unless @options['silent']
  end

  desc 'color', 'change the color of graphs'
  long_desc <<-LONGDESC
    Change the color of graphs

    ex) multiforecast color -k '2xx_count:#1111cc' '3xx_count:#11cc11' -c multiforecast.yml
  LONGDESC
  option :colors,    :type => :hash,   :aliases => '-k', :required => true, :banner => 'GRAPH_NAME:COLOR ...'
  option :base_path, :type => :string, :aliases => '-b'
  def color
    base_path = lstrip(options[:base_path], '/') if options[:base_path]
    graphs = @client.list_graph(base_path)
    setup_colors(options[:colors], graphs)
  end

  desc 'create_complex', 'create complex graphs'
  long_desc <<-LONGDESC
    Create complex graphs under a url

    ex) multiforecast create_complex -f 2xx_count 3xx_count -t status_count -c multiforecast.yml
  LONGDESC
  option :from_graphs, :type => :array,  :aliases => '-f', :required => true, :banner => 'GRAPH_NAMES ...'
  option :to_complex,  :type => :string, :aliases => '-t', :required => true
  option :base_path,   :type => :string, :aliases => '-b'
  def create_complex
    base_path = lstrip(options[:base_path], '/') if options[:base_path]
    graphs = @client.list_graph(base_path)
    setup_complex(options[:from_graphs], options[:to_complex], graphs)
  end

  private

  def delete_graphs(graphs, graph_names = nil)
    graphs.each do |graph|
      path = graph['path']
      next if graph_names and !graph_names.include?(File.basename(path))
      puts "Delete #{path}" unless @options['silent']
      exec { @client.delete_graph(path) }
    end
  end

  def delete_complexes(complexes, graph_names = nil)
    complexes.each do |graph|
      path = graph['path']
      next if graph_names and !graph_names.include?(File.basename(path))
      puts "Delete #{path}" unless @options['silent']
      exec { @client.delete_complex(path) }
    end
  end

  def setup_colors(colors, graphs)
    graphs.each do |graph|
      path = graph['path']
      next unless color = colors[File.basename(path)]
      data = { 'color' => color }
      puts "Setup #{path} with #{color}" unless @options['silent']
      exec { @client.edit_graph(path, data) }
    end
  end

  def setup_complex(from_graphs, to_complex, graphs)
    from_graph_first = from_graphs.first
    graphs.each do |graph|
      next unless File.basename(graph['path']) == from_graph_first
      dirname = File.dirname(graph['path'])

      base = {'gmode' => 'gauge', 'stack' => true, 'type' => 'AREA'}
      from_graphs_params = from_graphs.map {|name| base.merge('path' => "#{dirname}/#{name}") }
      to_complex_params = { 'path' => "#{dirname}/#{to_complex}", 'sort' => 0 }
      puts "Setup #{dirname}/#{to_complex} with #{from_graphs}" unless @options['silent']
      exec { @client.create_complex(from_graphs_params, to_complex_params) }
    end
  end

  def exec(&blk)
    begin
      yield
    rescue => e
      $stderr.puts "\tclass:#{e.class}\t#{e.message}"
    end
  end
end

