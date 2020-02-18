# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sn_foil/version'

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name          = 'snfoil'
  spec.version       = SnFoil::VERSION
  spec.authors     = ['Matthew Howes', 'Danny Murphy']
  spec.email       = ['howeszy@gmail.com', 'dmurph24@gmail.com']
  spec.summary       = 'A boilerplate gem for providing basic contexts'
  spec.homepage      = 'https://github.com/howeszy/snfoil'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  spec.files = [
    "lib/sn_foil/adapters/orms/base_adapter.rb",
    "lib/sn_foil/adapters/orms/active_record.rb",
    "lib/sn_foil/contexts/build_context.rb",
    "lib/sn_foil/contexts/change_context.rb",
    "lib/sn_foil/contexts/create_context.rb",
    "lib/sn_foil/contexts/destroy_context.rb",
    "lib/sn_foil/contexts/index_context.rb",
    "lib/sn_foil/contexts/setup_context.rb",
    "lib/sn_foil/contexts/show_context.rb",
    "lib/sn_foil/contexts/update_context.rb",
    "lib/sn_foil/context.rb",
    "lib/sn_foil/policy.rb",
    "lib/sn_foil/searcher.rb"
  ]

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 5.1'
  spec.add_dependency 'logger', '~> 1.0'
  spec.add_dependency 'pundit', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'pry-byebug', '~> 3.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'rubocop', '~> 0.76.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.36.0'
  spec.add_development_dependency 'dry-struct', '~> 1.0'
end
