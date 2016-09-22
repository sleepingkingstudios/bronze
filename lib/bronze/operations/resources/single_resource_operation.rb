# lib/bronze/operations/resources/single_resource_operation.rb

require 'sleeping_king_studios/tools/toolbox/mixin'
require 'bronze/operations/operation'
require 'bronze/operations/resources/resource_operation'

module Bronze::Operations::Resources
  # Base class implementing query and persistence functionality on a single
  # resource, such as a RESTful #show or #create method.
  class SingleResourceOperation < Bronze::Operations::Operation
    include Bronze::Operations::Resources::ResourceOperation

    # @return [Object] The root resource for the operation.
    attr_reader :resource

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
      collection.find(resource_id)
    end # method resource_id
  end # module
end # module
