# lib/bronze/collections/criteria/criterion.rb

require 'bronze/collections/criteria'

module Bronze::Collections::Criteria
  # Abstract class for a query criterion, which encodes a restriction or
  # expectation on the data returned from a datastore.
  class Criterion
    # Error class for handling unimplemented abstract query methods.
    class NotImplementedError < StandardError; end

    # The type of criterion. This value controls the order in which criteria are
    # applied. For example, applying a criterion that limits the number of
    # results before a criterion that orders the data will return incorrect
    # values.
    attr_reader :type

    # Applies the criterion to a native query or relation object. This method
    # must be overriden by collection-specific subclasses.
    def call *_args
      raise NotImplementedError,
        "#{self.class.name} does not implement #call",
        caller
    end # method call
  end # class
end # module
