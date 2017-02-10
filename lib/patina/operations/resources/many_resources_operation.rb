# lib/patina/operations/resources/many_resources_operation.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/operations/operation'

require 'patina/operations/resources/matching_resources_operation'

module Patina::Operations::Resources
  # Module implementing query and persistence functionality on a group of
  # resources filtered by primary keys.
  module ManyResourcesOperation
    extend  SleepingKingStudios::Tools::Toolbox::Mixin
    include Patina::Operations::Resources::MatchingResourcesOperation

    # @return [Integer] The number of resources expected.
    attr_reader :expected_count

    # Finds the requested instances of the resource class in the repository.
    #
    # @return [Array] The resources matching the requested parameters.
    def find_resources *resource_ids
      expected_ids    = resource_ids.flatten
      @expected_count = expected_ids.size

      super(:matching => { :id => { :__in => expected_ids } })
    end # method find_resources
  end # module
end # module
