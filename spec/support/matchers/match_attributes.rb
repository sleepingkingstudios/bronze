# frozen_string_literal: true

require 'rspec/sleeping_king_studios/matchers/core/deep_matcher'
require 'rspec/sleeping_king_studios/matchers/macros'

module RSpec::SleepingKingStudios::Matchers::Macros
  # @!method match_attributes
  #   @see RSpec::SleepingKingStudios::Matchers::Core::DeepMatcher#matches?
  alias_matcher :match_attributes, :deep_match
end
