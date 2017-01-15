# vendor/rspec/sleeping_king_studios/concerns/shared_example.rb

require 'rspec/sleeping_king_studios/concerns'

module RSpec::SleepingKingStudios::Concerns
  module SharedExample
    def shared_example name, &block
      shared_examples name do
        it &block
      end # shared_examples
    end # method shared_example
  end # module
end # module
