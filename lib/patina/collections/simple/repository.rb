# lib/patina/collections/simple/repository.rb

require 'bronze/collections/repository'
require 'bronze/entities/collections/entity_repository'

require 'patina/collections/simple/collection'
require 'patina/collections/simple/collection_builder'

module Patina::Collections::Simple
  # Coordinator object for creating collections around an in-memory data store.
  class Repository
    include Bronze::Collections::Repository
    include Bronze::Entities::Collections::EntityRepository

    def initialize
      @collection_builder = Patina::Collections::Simple::CollectionBuilder

      @data = Hash.new { |hsh, key| hsh[key] = [] }
    end # method initialize

    private

    attr_reader :data

    def build_collection collection_name
      collection_builder.new(collection_name, @data)
    end # method build_collection
  end # class
end # module
