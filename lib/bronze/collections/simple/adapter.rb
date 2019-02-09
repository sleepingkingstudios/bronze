# frozen_string_literal: true

require 'bronze/collections/adapter'
require 'bronze/collections/simple'
require 'bronze/collections/simple/query'

module Bronze::Collections::Simple
  # Adapter class for querying and modifying an in-memory data structure.
  class Adapter < Bronze::Collections::Adapter
    # @param data [Hash<String, Array<Hash>>] The stored data.
    def initialize(data)
      @data = data
    end

    # [Hash<String, Array<Hash>>] the stored data.
    attr_reader :data

    # (see Bronze::Collections::Adapter#collection_names)
    def collection_names
      data.keys.sort
    end

    # (see Bronze::Collections::Adapter#query)
    def query(collection_name)
      Bronze::Collections::Simple::Query.new(data[collection_name] ||= [])
    end
  end
end
