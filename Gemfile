# Gemfile

source 'https://rubygems.org'

gem 'sysrandom', '~> 1.0.0', '>= 1.0.2'
gem 'thor',      '~> 0.19',  '>= 0.19.1'

gem 'sleeping_king_studios-tools',
  '>= 0.5.0.alpha',
  :git    => 'https://github.com/sleepingkingstudios/sleeping_king_studios-tools',
  :branch => 'master'

group :doc do
  gem 'yard', '~> 0.9', '>= 0.9.5', :require => false
end # group

group :test do
  gem 'byebug', '~> 9.0', '~> 9.0.5'

  gem 'rspec',                       '~> 3.5'
  gem 'rspec-sleeping_king_studios', '~> 2.2', '>= 2.2.1'

  # Use Rubocop for evaluating and maintaining code quality.
  gem 'rubocop', '~> 0.42'

  # Use Simplecov to measure code coverages.
  gem 'simplecov', '~> 0.12', :require => false
  gem 'simplecov-json',
    '~> 0.2',
    :git     => 'https://github.com/sleepingkingstudios/simplecov-json',
    :branch  => 'master',
    :require => false
end # group
