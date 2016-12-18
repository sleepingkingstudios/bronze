# lib/patina/operations/resources/destroy_one_resource_operation.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'patina/operations/resources/one_resource_operation'

module Patina::Operations::Resources
  # Operation module to remove a persisted resource from the datastore.
  module DestroyOneResourceOperation
    extend  SleepingKingStudios::Tools::Toolbox::Mixin
    include Patina::Operations::Resources::OneResourceOperation

    private

    def process resource_id
      return unless require_resource(resource_id)

      _, @errors = resource_collection.delete resource_id
    end # method process
  end # module
end # module
