# lib/bronze/operations/resources/create_resource_operation.rb

require 'bronze/operations/resources/single_resource_operation'

module Bronze::Operations::Resources
  # Base class implementing query and persistence functionality on a single
  # resource, such as a RESTful #show or #create method.
  class CreateResourceOperation < SingleResourceOperation
    private

    def process attributes
      build_resource(attributes)

      result, @errors = resource_collection.insert @resource

      result
    end # method process
  end # class
end # module
