# lib/patina/operations/resources/many_resources_operation.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/operations/operation'
require 'patina/operations/resources/resource_operation'

module Patina::Operations::Resources
  # Module implementing query and persistence functionality on a group of
  # resources, such as a RESTful #index method or a bulk operation.
  module ManyResourcesOperation
    extend  SleepingKingStudios::Tools::Toolbox::Mixin
    include Patina::Operations::Resources::ResourceOperation

    # @return [Array] The root resource for the operation.
    attr_reader :resources

    private

    # Finds the requested instances of the resource class in the repository.
    #
    # @return [Array] The resources matching the requested parameters.
    def find_resources matching: nil
      query = resource_query

      query = query.matching(matching) if matching.is_a?(Hash)

      @resources = query.to_a
    end # method find_resources

    def resource_query
      @resource_query ||= resource_collection.query
    end # method resource_query
  end # module
end # module
