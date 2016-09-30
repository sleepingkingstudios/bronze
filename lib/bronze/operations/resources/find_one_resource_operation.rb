# lib/bronze/operations/resources/find_one_resource_operation.rb

require 'bronze/collections/collection'
require 'bronze/operations/resources/one_resource_operation'

module Bronze::Operations::Resources
  # Operation class to find a specific resource from a datastore.
  class FindOneResourceOperation < OneResourceOperation
    private

    def process resource_id
      find_resource resource_id

      return if @resource

      error_definitions = Bronze::Collections::Collection::Errors

      @errors[:resource].add(
        error_definitions::RECORD_NOT_FOUND,
        :id,
        resource_id
      ) # end add error
    end # method process
  end # class
end # module
