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
    def initialize collection_type, mongo_collection
      super(collection_type)

      @mongo_collection = mongo_collection
    end # constructor

    # (see Bronze::Collections::CollectionBuilder#collection_class)
    def collection_class
      Patina::Collections::Mongo::Collection
    end # method collection_class

    private

    attr_reader :mongo_collection

    def build_collection
      collection_class.new(mongo_collection)
    end # method
  end # class
end # module
