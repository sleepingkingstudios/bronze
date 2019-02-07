# frozen_string_literal: true

require 'bronze/collections'
require 'bronze/not_implemented_error'

module Bronze::Collections
  # Abstract class defining the interface for collection adapters, which
  # allow collections to interact with different underlying data stores.
  class Adapter
    # @overload(collection_name)
    #   @return [Bronze::Collections::Query] a query against the data store.
    #
    #   @raise Bronze::NotImplementedError unless overriden by an Adapter
    #     subclass.
    def query(_collection_name)
      raise Bronze::NotImplementedError.new(self, :query)
    end
  end
end
