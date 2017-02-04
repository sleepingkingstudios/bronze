# lib/patina/operations/resources/create_one_resource_operation.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'patina/operations/resources/one_resource_operation'

module Patina::Operations::Resources
  # Operation module to build, validate and persist an instance of a resource
  # from an attributes hash.
  module CreateOneResourceOperation
    extend  SleepingKingStudios::Tools::Toolbox::Mixin
    include Patina::Operations::Resources::OneResourceOperation

    private

    def process attributes
      build_resource(attributes)

      unless validate_resource(@resource)
        @failure_message = INVALID_RESOURCE

        return
      end # unless

      result, @errors = resource_collection.insert @resource

      resource.persist if result
    end # method process
  end # module
end # module
