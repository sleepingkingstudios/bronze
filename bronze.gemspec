# frozen_string_literal: true

$LOAD_PATH << './lib'

require 'bronze/version'

Gem::Specification.new do |gem| # rubocop:disable Metrics/BlockLength
  gem.name = 'bronze'
  gem.version = Bronze::VERSION
  gem.date = Time.now.utc.strftime '%Y-%m-%d'
  gem.summary = 'A composable application framework.'

  description = <<~DESCRIPTION
    A composable application toolkit, providing data entities and collections,
    transforms, contract-based validations and pre-built operations.
    Architecture agnostic for easy integration with other toolkits or
    frameworks.
  DESCRIPTION
  gem.description = description.strip.gsub(/\n +/, ' ')
  gem.authors = ['Rob "Merlin" Smith']
  gem.email = ['merlin@sleepingkingstudios.com']
  gem.homepage = 'http://sleepingkingstudios.com'
  gem.license = 'MIT'

  gem.require_path = 'lib'
  gem.files = Dir['lib/**/*.rb', 'LICENSE', '*.md']

  gem.add_runtime_dependency 'cuprum', '~> 0.8'
  gem.add_runtime_dependency 'sysrandom', '~> 1.0.0', '>= 1.0.2'
  gem.add_runtime_dependency \
    'sleeping_king_studios-tools', '~> 0.7', '>= 0.7.1'

  gem.add_development_dependency 'rspec', '~> 3.8'
  gem.add_development_dependency \
    'rspec-sleeping_king_studios', '~> 2.4', '>= 2.4.1'
  gem.add_development_dependency 'rubocop', '~> 0.61', '>= 0.61.1'
  gem.add_development_dependency 'rubocop-rspec', '~> 1.30', '>= 1.30.1'
  gem.add_development_dependency 'simplecov', '~> 0.16', '>= 0.16.1'
  gem.add_development_dependency 'thor', '~> 0.20', '>= 0.20.3'
end
