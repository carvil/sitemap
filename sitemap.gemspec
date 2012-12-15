# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sitemap/version'

Gem::Specification.new do |gem|
  gem.name          = "sitemap"
  gem.version       = Sitemap::VERSION
  gem.authors       = ["Carlos Vilhena"]
  gem.email         = ["carlosvilhena@gmail.com"]
  gem.description   = %q{Crawls a domain to obtain a sitemap}
  gem.summary       = %q{Crawls a domain to obtain a sitemap}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "thor"
  gem.add_runtime_dependency 'faraday', '~> 0.8.4'
  gem.add_runtime_dependency 'faraday_middleware', '~> 0.9.0'
  gem.add_runtime_dependency 'nokogiri', '~> 1.5.5'
  gem.add_runtime_dependency 'rgl', '~> 0.4.0'

  gem.add_development_dependency 'rspec', '~> 2.12.0'
  gem.add_development_dependency 'vcr', '~> 2.3.0'
  gem.add_development_dependency 'webmock', '~> 1.8.3'
end
