# lib/bronze/collections/null_collection.rb

require 'bronze/collections/collection'

module Bronze::Collections
  # A collection object representing an empty dataset.
  class NullCollection
    include Bronze::Collections::Collection

    def initialize
      super(nil)
    end # constructorss

    private

    def base_query
      Bronze::Collections::NullQuery.new
    end # method base_query

    def delete_one _id
      build_errors.add(Errors::READ_ONLY_COLLECTION)
    end # method delete_one

    def insert_one _attributes
      build_errors.add(Errors::READ_ONLY_COLLECTION)
    end # method insert_one

    def update_one _id, _attributes
      build_errors.add(Errors::READ_ONLY_COLLECTION)
    end # method delete_one
  end # class
end # module
