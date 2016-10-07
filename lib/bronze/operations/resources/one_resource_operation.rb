# lib/bronze/operations/resources/one_resource_operation.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/collections/collection'
require 'bronze/operations/operation'
require 'bronze/operations/resources/resource_operation'

module Bronze::Operations::Resources
  # Base class implementing query and persistence functionality on a single
  # resource, such as a RESTful #show or #create method.
  class OneResourceOperation < Bronze::Operations::Operation
    include Bronze::Operations::Resources::ResourceOperation

    # @return [Object] The root resource for the operation.
    attr_reader :resource

    private

    # Builds an instance of the resource class with the given attributes.
    #
    # @param attributes [Hash] The attributes for the resource.
    #
    # @return [Object] The resource.
    def build_resource attributes
      @resource = resource_class.new(attributes)
    end # method build_resource

    # Finds the requested instance of the resource class in the repository.
    #
    # @param resource_id [String] The id of the requested resource.
    #
    # @return [Object] The resource.
    def find_resource resource_id
      @resource = resource_collection.find(resource_id)
    end # method resource_id

    # Finds the requested instance of the resource class in the repository. If
    # the resource cannot be found, adds an error to the operation errors.
    #
    # @param resource_id [String] The id of the requested resource.
    #
    # @return [Boolean] True if the resource has been found, otherwise false.
    def require_resource resource_id
      return true if find_resource(resource_id)

      error_definitions = Bronze::Collections::Collection::Errors

      @errors[resource_key].add(
        error_definitions::RECORD_NOT_FOUND,
        :id,
        resource_id
      ) # end errors

      false
    end # method require_resource

    def resource_key
      :resource
    end # method resource_key
  end # module
end # module