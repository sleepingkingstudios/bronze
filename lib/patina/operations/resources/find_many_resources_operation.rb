# lib/patina/operations/resources/find_many_resources_operation.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'patina/operations/resources/many_resources_operation'

module Patina::Operations::Resources
  # Operation module to find specific resources from a datastore.
  module FindManyResourcesOperation
    extend  SleepingKingStudios::Tools::Toolbox::Mixin
    include Patina::Operations::Resources::ManyResourcesOperation

    private

    def process resource_ids
      require_resources resource_ids
    end # method process
  end # module
end # module
