#! /usr/bin/env gem build
# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name          = 'multiforecast-client'
  gem.version       = File.read(File.expand_path('VERSION', File.dirname(__FILE__))).chomp
  gem.authors       = ["Naotoshi Seo"]
  gem.email         = ["sonots@gmail.com"]
  gem.homepage      = "https://github.com/sonots/multiforecast-client"
  gem.summary       = "Multiple GrowthForecast Client"
  gem.description   = gem.summary

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "growthforecast-client"

  # for testing
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec", "~> 2.11"
  gem.add_development_dependency "webmock"

  # for debug
  gem.add_development_dependency "pry"
  gem.add_development_dependency "tapp"
end
