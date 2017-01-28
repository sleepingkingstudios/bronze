# lib/patina/collections/mongo/collection_builder.rb

require 'bronze/collections/collection_builder'

require 'patina/collections/mongo'
require 'patina/collections/mongo/collection'

module Patina::Collections::Mongo
  # Builder object for creating instances of
  # Patina::Collections::Mongo::Collection.
  class CollectionBuilder < ::Bronze::Collections::CollectionBuilder
    # @param (see Bronze::Collections::CollectionBuilder#initialize)
    # @param mongo_collection [::Mongo::Collection] The collection object for
    #   the data from the native Mongo ruby driver.
    def initialize collection_type, mongo_client
      super(collection_type)

      @mongo_client = mongo_client
    end # constructor

    # (see Bronze::Collections::CollectionBuilder#collection_class)
    def collection_class
      Patina::Collections::Mongo::Collection
    end # method collection_class

    # @return [String] The name of the collection.
    def collection_name
      @collection_name ||=
        if collection_type.is_a?(Class)
          fragments = collection_type.name.split('::').map do |fragment|
            string_tools.underscore(fragment)
          end # map
          fragments[-1] = string_tools.pluralize(fragments.last)

          fragments.join('.')
        else
          normalize_collection_name(collection_type)
        end # if-else
    end # method collection_name

    private

    attr_reader :mongo_client

    def build_collection
      mongo_collection = mongo_client[collection_name]

      collection_class.new(mongo_collection)
    end # method
  end # class
end # module
