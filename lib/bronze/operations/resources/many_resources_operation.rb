# lib/bronze/operations/resources/many_resources_operation.rb

require 'bronze/operations/operation'
require 'bronze/operations/resources/resource_operation'

module Bronze::Operations::Resources
  # Base class implementing query and persistence functionality on a group of
  # resources, such as a RESTful #index method or a bulk operation.
  class ManyResourcesOperation < Bronze::Operations::Operation
    include Bronze::Operations::Resources::ResourceOperation

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
  end # class
end # class
