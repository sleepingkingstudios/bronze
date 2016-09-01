# lib/patina/collections/simple/repository.rb

require 'bronze/collections/repository'
require 'patina/collections/simple/collection'

module Patina::Collections::Simple
  # Coordinator object for creating collections around an in-memory data store.
  class Repository
    include Bronze::Collections::Repository

    def initialize
      @data = Hash.new { |hsh, key| hsh[key] = [] }
    end # method initialize

    private

    attr_reader :data

    def build_collection collection_name, transform
      name = normalize_collection_name collection_name

      collection = collection_class.new(data[name], transform)

      collection.send :name=,       name
      collection.send :repository=, self

      collection
    end # method build_collection

    def collection_class
      Patina::Collections::Simple::Collection
    end # method collection_class

    def normalize_collection_name name
      tools = ::SleepingKingStudios::Tools::StringTools
      name  = tools.underscore(name.to_s)
      name  = tools.pluralize(name)

      name.intern
    end # method normalize_collection_name
  end # class
end # module
