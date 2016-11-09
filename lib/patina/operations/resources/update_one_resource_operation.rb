# lib/patina/operations/resources/update_one_resource_operation.rb

require 'patina/operations/resources/one_resource_operation'

module Patina::Operations::Resources
  # Operation class to build, validate and persist an instance of a resource
  # from an attributes hash.
  class UpdateOneResourceOperation < OneResourceOperation
    private

    def process resource_id, attributes
      return unless require_resource(resource_id)

      resource.assign(attributes)

      return unless validate_resource(@resource)

      _, @errors = resource_collection.update resource_id, @resource
    end # method process
  end # class
end # module
