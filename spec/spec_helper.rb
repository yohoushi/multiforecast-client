# encoding: utf-8
require "bundler/setup"

ENV['MOCK'] ||= 'on'
require "pry"
require 'mgclient'
require 'webmock/rspec'
WebMock.allow_net_connect! if ENV['MOCK'] == 'off'

ROOT = File.dirname(__FILE__)
Dir[File.expand_path("support/**/*.rb", ROOT)].each {|f| require f }

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
end

def e(str)
  URI.escape(str) if str
end

def gfpath(path)
  URI.escape("#{service_name(path)}/#{section_name(path)}/#{graph_name(path)}")
end

def base_uri
  'http://localhost:5125'
end

def client
  Mg::Client.new({dir: '', gfuri: base_uri})
end