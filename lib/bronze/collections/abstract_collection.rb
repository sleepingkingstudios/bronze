# lib/bronze/collections/abstract_collection.rb

require 'bronze/collections/collection'

module Bronze::Collections
  # An abstract class that includes Collection and provides a mock
  # implementation of the required querying and persistence methods. Developers
  # may choose to subclass AbstractCollection or to include Collection in their
  # own classes.
  #
  # (see Collection)
  class AbstractCollection
    # Error class for handling unimplemented abstract collection methods.
    # Subclasses of AbstractCollection must implement these methods as
    # appropriate for the datastore.
    class NotImplementedError < StandardError; end

    include Bronze::Collections::Collection

    private

    def base_query
      not_implemented :base_query
    end # method base_query

    def delete_one _id
      not_implemented :delete_one
    end # method delete_one

    def insert_one _attributes
      not_implemented :insert_one
    end # method insert_one

    def not_implemented method_name
      raise NotImplementedError,
        "#{self.class.name} does not implement :#{method_name}",
        caller[1..-1]
    end # method not_implemented

    def update_one _id, _attributes
      not_implemented :update_one
    end # method update_one
  end # class
end # module
