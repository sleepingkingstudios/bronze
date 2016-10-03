# spec/bronze/collections/reference/repository.rb

require 'bronze/collections/reference'
require 'bronze/collections/reference/collection_builder'
require 'bronze/collections/repository'

module Bronze::Collections::Reference
  # Reference implementation of Bronze::Collections::Repository.
  class Repository
    include ::Bronze::Collections::Repository

    def initialize
      @collection_builder = Bronze::Collections::Reference::CollectionBuilder

      @data = Hash.new { |hsh, key| hsh[key] = [] }
    end # method initialize

    private

    attr_reader :data

    def build_collection collection_name
      collection_builder.new(collection_name, @data)
    end # method build_collection
  end # class
end # module
