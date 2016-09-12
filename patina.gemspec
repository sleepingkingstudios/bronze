# patina.gemspec

$: << './lib'
require 'patina/version'

Gem::Specification.new do |gem|
  gem.name        = 'patina'
  gem.version     = Patina::VERSION
  gem.date        = Time.now.utc.strftime "%Y-%m-%d"
  gem.summary     = 'Extensions for the Bronze application framework.'

  description = <<-DESCRIPTION
    Extensions and concrete implementations of the Bronze application tools and
    patterns.
  DESCRIPTION
  gem.description = description.strip.gsub(/\n +/, ' ')

  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'MIT'

  gem.require_path = 'lib'
  gem.files        = Dir["lib/**/*.rb", "LICENSE", "*.md"]

  gem.add_runtime_dependency 'bronze'
end # gemspec
