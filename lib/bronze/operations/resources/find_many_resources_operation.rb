# lib/bronze/operations/resources/find_many_resources_operation.rb

require 'bronze/operations/resources/many_resources_operation'

module Bronze::Operations::Resources
  # Operation class to query resources from a datastore.
  class FindManyResourcesOperation < ManyResourcesOperation
    private

    def process matching: nil
      find_resources :matching => matching
    end # method process
  end # class
end # module
