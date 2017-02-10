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

    # Failure message when one or more expected resources are not found.
    RESOURCES_NOT_FOUND = 'operations.resources.resources_not_found'.freeze

    # @return [Integer] The number of resources expected.
    attr_reader :expected_count

    # @return [Array] The ids of resources that were requested but not found.
    attr_reader :missing_resource_ids

    private

    def append_missing_resource_errors
      error_definitions = Bronze::Collections::Collection::Errors

      missing_resource_ids.each do |missing_id|
        @errors[resources_key][missing_id].add(
          error_definitions::RECORD_NOT_FOUND,
          :id => missing_id
        ) # end errors
      end # each
    end # method append_missing_resource_errors

    # Finds the requested instances of the resource class in the repository.
    #
    # @param [Array] The resources matching the requested parameters.
    #
    # @return [Array] The found resources.
    def find_resources *resource_ids
      expected_ids    = resource_ids.flatten
      @expected_count = expected_ids.size

      super(:matching => { :id => { :__in => expected_ids } })

      if resources_count < expected_count
        found_ids = resources.map(&:id)

        @missing_resource_ids = expected_ids - found_ids
      else
        @missing_resource_ids = []
      end # if-else

      @resources
    end # method find_resources

    # Finds the requested instances of the resource class in the repository. If
    # the resource cannot be found, adds an error to the operation errors for
    # each missing resource.
    #
    # @param resource_id [String] The id of the requested resource.
    #
    # @return [Boolean] True if the resource has been found, otherwise false.
    def require_resources *resource_ids
      find_resources(*resource_ids)

      return true if resources_count == expected_count

      append_missing_resource_errors

      @failure_message = RESOURCES_NOT_FOUND

      false
    end # method require_resource

    def resources_key
      :resources
    end # method resources_key
  end # module
end # module
