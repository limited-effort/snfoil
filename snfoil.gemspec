# frozen_string_literal: true

require_relative 'lib/snfoil/version'

Gem::Specification.new do |spec|
  spec.name          = 'snfoil'
  spec.version       = SnFoil::VERSION
  spec.authors     = ['Matthew Howes', 'Cliff Campbell']
  spec.email       = ['matt.howes@limitedeffort.io', 'cliffcampbell@hey.com']

  spec.summary       = 'A Toolbox of Context Behaviors'
  spec.description   = 'A collection of SnFoil gems and additional helper classes'
  spec.homepage      = 'https://github.com/limited-effort/snfoil'
  spec.license       = 'Apache-2.0'
  spec.required_ruby_version = '>=3.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/limited-effort/snfoil/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  ignore_list = %r{\A(?:test/|spec/|bin/|features/|Rakefile|\.\w)}
  spec.files = Dir.chdir(File.expand_path(__dir__)) { `git ls-files -z`.split("\x0").reject { |f| f.match(ignore_list) } }

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 5.2.6'
  spec.add_dependency 'logger', '~> 1.0'
  spec.add_dependency 'pundit', '~> 2.0'
  spec.add_dependency 'snfoil-context', '>= 1.1.0', '< 2.0'
  spec.add_dependency 'snfoil-policy', '>= 1.1.0', '< 2.0'
  spec.add_dependency 'snfoil-searcher', '>= 1.1.0', '< 2.0'
end
