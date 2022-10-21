# frozen_string_literal: true

require_relative 'lib/alexandrite/version'

Gem::Specification.new do |spec|
  spec.name          = 'alexandrite'
  spec.version       = Alexandrite::VERSION
  spec.authors       = ['Eftakhairul Islam', 'J. P. Pérez-Tejada']
  spec.email         = ['eftakhairul@gmail.com', 'juan@daiuk.com']
  spec.summary       = 'Book information from ISBN by Google Book API.'
  spec.description   = "Alexandrite is a gem that fetches public book's information by different params based
on Google Book API. Powered by Faraday."
  spec.homepage      = 'https://github.com/maclenn77/alexandrite'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.0')
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 2.1.0'
  spec.add_development_dependency 'faraday'
  spec.add_development_dependency 'rake'

  # #dependency for testing automation
  spec.add_development_dependency 'factory_bot'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-nc'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
end
