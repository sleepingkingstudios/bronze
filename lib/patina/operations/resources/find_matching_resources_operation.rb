# lib/patina/operations/resources/find_matching_resources_operation.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'patina/operations/resources/many_resources_operation'

module Patina::Operations::Resources
  # Operation module to query resources from a datastore.
  module FindMatchingResourcesOperation
    extend  SleepingKingStudios::Tools::Toolbox::Mixin
    include Patina::Operations::Resources::ManyResourcesOperation

    private

    def process matching: nil
      find_resources :matching => matching
    end # method process
  end # module
end # module
