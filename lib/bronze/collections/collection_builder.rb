# lib/bronze/collections/collection_builder.rb

require 'bronze/collections'

module Bronze::Collections
  # Builder object for creating instances of a Collection based on a shared
  # base and configuration options.
  class CollectionBuilder
    # Error class for handling unimplemented builder methods. Classes that
    # inherit from CollectionBuilder must implement these methods.
    class NotImplementedError < StandardError; end

    # @param collection_type [Object] Object specifying the type of collection
    #   to create. May be the name of the collection, the class of object that
    #   the collection serializes, or another value. The collection builder is
    #   responsible for resolving this object into a name and class for the
    #   created collection object.
    def initialize collection_type
      @collection_type = collection_type
    end # constructor

    # @return [Class] The class of the collection.
    attr_reader :collection_class

    # @return [Object] Object specifying the type of collection to create.
    attr_reader :collection_type

    # Builds a new collection of the specified type and (optionally) with the
    # specified transform.
    #
    # @param transform [Bronze::Transforms::Transform]
    def build transform = nil
      collection = build_collection

      collection.send :name=,      collection_name
      collection.send :transform=, transform || build_transform

      collection
    end # method build

    # @return [String] The name of the collection.
    def collection_name
      @collection_name ||=
        if collection_type.is_a?(Class)
          name = collection_type.name.split('::').last

          normalize_collection_name(name)
        else
          normalize_collection_name(collection_type)
        end # if-else
    end # method collection_name

    private

    def build_collection
      raise NotImplementedError,
        "#{self.class.name} does not implement :build_collection",
        caller
    end # method build_collection

    def build_transform
      nil
    end # method default_transform

    def normalize_collection_name name
      tools = ::SleepingKingStudios::Tools::StringTools
      name  = tools.underscore(name.to_s)
      name  = tools.pluralize(name)

      name
    end # method normalize_collection_name
  end # class
end # module
