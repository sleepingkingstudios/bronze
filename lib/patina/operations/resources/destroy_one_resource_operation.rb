# lib/patina/operations/resources/destroy_one_resource_operation.rb

require 'patina/operations/resources/one_resource_operation'

module Patina::Operations::Resources
  # Operation class to build, validate and persist an instance of a resource
  # from an attributes hash.
  class DestroyOneResourceOperation < OneResourceOperation
    private

    def process resource_id
      return unless require_resource(resource_id)

      _, @errors = resource_collection.delete resource_id
    end # method process
  end # class
end # module
