# lib/patina/collections/mongo/repository.rb

require 'bronze/collections/repository'
require 'bronze/entities/collections/entity_repository'

require 'patina/collections/mongo/collection'
require 'patina/collections/mongo/collection_builder'

module Patina::Collections::Mongo
  # Coordinator object for creating collections around a MongoDB schemaless
  # datastore.
  class Repository
    include Bronze::Collections::Repository
    include Bronze::Entities::Collections::EntityRepository

    def initialize mongo_client
      @collection_builder = Patina::Collections::Mongo::CollectionBuilder
      @mongo_client       = mongo_client
    end # method initialize

    attr_reader :mongo_client

    private

    def build_collection collection_name
      collection_builder.new(collection_name, mongo_client)
    end # method build_collection
  end # class
end # module
