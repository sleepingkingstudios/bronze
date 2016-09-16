# bronze.gemspec

$: << './lib'
require 'bronze/version'

Gem::Specification.new do |gem|
  gem.name        = 'bronze'
  gem.version     = Bronze::VERSION
  gem.date        = Time.now.utc.strftime "%Y-%m-%d"
  gem.summary     = 'A composable application framework.'

  description = <<-DESCRIPTION
    A set of objects and tools for building composable applications without the
    conceptual overhead of common frameworks. Allows the developer to
    incorporate other architectures by composition without forcing foreign
    constraints on your business logic.
  DESCRIPTION
  gem.description = description.strip.gsub(/\n +/, ' ')

  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'MIT'

  gem.require_path = 'lib'
  gem.files        = Dir["lib/**/*.rb", "LICENSE", "*.md"]

  gem.add_runtime_dependency 'sysrandom', '~> 1.0.0', '>= 1.0.2'
  gem.add_runtime_dependency 'sleeping_king_studios-tools'

  gem.add_development_dependency 'thor',      '~> 0.19',  '>= 0.19.1'
  gem.add_development_dependency 'rspec',     '~> 3.5'
  gem.add_development_dependency 'rubocop',   '~> 0.42'
  gem.add_development_dependency 'simplecov', '~> 0.12'
  gem.add_development_dependency 'rspec-sleeping_king_studios',
    '~> 2.2', '>= 2.2.1'
end # gemspec