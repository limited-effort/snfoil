# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'sn_foil/version'

Gem::Specification.new do |spec|
  spec.name          = 'snfoil'
  spec.version       = SnFoil::VERSION
  spec.required_ruby_version = '>= 2.5.0'
  spec.authors     = ['Matthew Howes', 'Danny Murphy', 'Cliff Campbell']
  spec.email       = ['howeszy@gmail.com', 'dmurph24@gmail.com', 'cliffcampbell@hey.com']
  spec.summary       = 'A boilerplate gem for providing basic contexts'
  spec.homepage      = 'https://github.com/limited-effort/snfoil'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir['{lib}/**/*.rb', 'Rakefile', 'LICENSE', '*.md']

  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_path = 'lib'

  spec.add_dependency 'activesupport', '>= 5.2.6'
  spec.add_dependency 'logger', '~> 1.0'
  spec.add_dependency 'pundit', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 2.2'
  spec.add_development_dependency 'dry-struct', '~> 1.0'
  spec.add_development_dependency 'pry-byebug', '~> 3.9'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'rubocop', '~> 1.18'
  spec.add_development_dependency 'rubocop-performance', '~> 1.11'
  spec.add_development_dependency 'rubocop-rails', '~> 2.11'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.4'
end
