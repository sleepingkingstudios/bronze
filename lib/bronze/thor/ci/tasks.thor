# lib/bronze/thor/ci/tasks.thor

require 'rubocop'

require 'bronze/thor/ci/default'
require 'bronze/thor/ci/rspec'
require 'bronze/thor/ci/rubocop'

module Bronze::Thor::Ci
  # Defines a Thor task for running Rubocop.
  class Tasks < ::Thor
    namespace :"bronze:ci"

    include Bronze::Thor::Ci::Default
    include Bronze::Thor::Ci::RSpec
    include Bronze::Thor::Ci::Rubocop
  end # class
end # module
