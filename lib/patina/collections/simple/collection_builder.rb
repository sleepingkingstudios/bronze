# lib/patina/collections/simple/collection_builder.rb

require 'bronze/collections/collection_builder'
require 'patina/collections/simple/collection'

module Patina::Collections::Simple
  # Builder object for creating instances of
  # Patina::Collections::SimpleCollection.
  class CollectionBuilder < ::Bronze::Collections::CollectionBuilder
    # @param (see Bronze::Collections::CollectionBuilder#initialize)
    # @param @data [Hash] The repository's data hash.
    def initialize collection_type, data
      super(collection_type)

      @data = data
    end # constructor

    # (see Bronze::Collections::CollectionBuilder#collection_class)
    def collection_class
      Patina::Collections::Simple::Collection
    end # method collection_class

    # (see Bronze::Collections::CollectionBuilder#collection_name)
    def collection_name
      @collection_name ||= normalize_collection_name collection_type
    end # method

    private

    attr_reader :data

    def build_collection
      collection_class.new(data[collection_name])
    end # method

    def normalize_collection_name name
      tools = ::SleepingKingStudios::Tools::StringTools
      name  = tools.underscore(name.to_s)
      name  = tools.pluralize(name)

      name.intern
    end # method normalize_collection_name
  end # class
end # module
