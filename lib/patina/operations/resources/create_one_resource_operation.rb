# lib/patina/operations/resources/create_one_resource_operation.rb

require 'patina/operations/resources/one_resource_operation'

module Patina::Operations::Resources
  # Operation class to build, validate and persist an instance of a resource
  # from an attributes hash.
  class CreateOneResourceOperation < OneResourceOperation
    private

    def process attributes
      build_resource(attributes)

      return unless validate_resource(@resource)

      _, @errors = resource_collection.insert @resource
    end # method process
  end # class
end # module
