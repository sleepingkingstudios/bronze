# lib/patina/operations/resources/find_one_resource_operation.rb

require 'bronze/collections/collection'
require 'patina/operations/resources/one_resource_operation'

module Patina::Operations::Resources
  # Operation class to find a specific resource from a datastore.
  class FindOneResourceOperation < OneResourceOperation
    private

    def process resource_id
      require_resource resource_id
    end # method process
  end # class
end # module