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

    ex)
    $ multiforecast post '{"number":0}' 'test/test' -c multiforecast.yml
  LONGDESC
  def post(json, path)
    path = lstrip(path, '/')
    exec do
      res = @client.post_graph(path, JSON.parse(json))
      $stdout.puts res unless @options['silent']
    end
  end

  desc 'delete <base_path>', 'Delete a graph or graphs under a path'
  long_desc <<-LONGDESC
    Delete a graph or graphs under a path

    ex)
    $ multiforecast delete 'test/test' -c multiforecast.yml
  LONGDESC
  def delete(base_path)
    base_path = lstrip(base_path, '/')
    graphs = @client.list_graph(base_path)
    graphs.each do |graph|
      exec do
        @client.delete_graph(graph['path'])
        $stdout.puts "Deleted #{graph['path']}" unless @options['silent']
      end
    end
    complexes = @client.list_complex(base_path)
    complexes.each do |graph|
      exec do
        @client.delete_complex(graph['path'])
        $stdout.puts "Deleted #{graph['path']}" unless @options['silent']
      end
    end
    $stderr.puts "Not found" if graphs.empty? and complexes.empty? unless @options['silent']
  end

  private
  def exec(&blk)
    begin
      yield
    rescue => e
      $stderr.puts "\tclass:#{e.class}\t#{e.message}"
    end
  end
end

