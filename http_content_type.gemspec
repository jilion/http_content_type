# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'http_content_type/version'

Gem::Specification.new do |s|
  s.name          = 'http_content_type'
  s.version       = HttpContentType::VERSION
  s.license       = 'MIT'
  s.authors       = ['Rémy Coutable']
  s.email         = ['remy@rymai.me']
  s.summary       = 'Check the Content-Type of any HTTP-accessible asset.'
  s.description   = 'This gem allows you to check the Content-Type of any HTTP-accessible asset.'
  s.homepage      = 'http://rubygems.org/gems/http_content_type'

  s.files         = Dir.glob('lib/**/*') + %w[CHANGELOG.md LICENSE.md README.md]
  s.test_files    = Dir.glob('spec/**/*')
  s.require_paths = ['lib']

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec'
end
