# lib/patina/operations/resources/update_one_resource_operation.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'patina/operations/resources/one_resource_operation'

module Patina::Operations::Resources
  # Operation module to update, validate and persist an instance of a resource
  # from an attributes hash.
  module UpdateOneResourceOperation
    extend  SleepingKingStudios::Tools::Toolbox::Mixin
    include Patina::Operations::Resources::OneResourceOperation

    private

    def process resource_id, attributes
      return unless require_resource(resource_id)

      resource.assign(attributes)

      unless validate_resource(@resource)
        @failure_message = INVALID_RESOURCE

        return
      end # unless

      result, @errors = resource_collection.update resource_id, @resource

      @resource.clean_attributes if result
    end # method process
  end # module
end # module
