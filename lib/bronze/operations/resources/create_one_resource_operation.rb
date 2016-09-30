# lib/bronze/operations/resources/create_one_resource_operation.rb

require 'bronze/operations/resources/one_resource_operation'

module Bronze::Operations::Resources
  # Operation class to build, validate and persist an instance of a resource
  # from an attributes hash.
  class CreateOneResourceOperation < OneResourceOperation
    private

    def process attributes
      build_resource(attributes)

      _, @errors = resource_collection.insert @resource
    end # method process
  end # class
end # module
