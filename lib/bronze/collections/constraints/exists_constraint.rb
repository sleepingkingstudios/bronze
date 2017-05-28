# lib/bronze/collections/constraints/exists_constraint.rb

require 'bronze/collections/constraints/collection_constraint'
require 'bronze/constraints/constraint'

module Bronze::Collections::Constraints
  # Constraint evaluating the presence of an object in the collection that
  # matches the given query.
  class ExistsConstraint < Bronze::Constraints::Constraint
    include Bronze::Collections::Constraints::CollectionConstraint

    # Error message for objects that match the constraint.
    DOES_NOT_EXIST_ERROR =
      'constraints.errors.messages.does_not_exist'.freeze

    # Error message for objects that do not match the constraint.
    EXISTS_ERROR =
      'constraints.errors.messages.exists'.freeze

    private

    def build_errors object
      super.add(DOES_NOT_EXIST_ERROR, :matching => object)
    end # method build_errors

    def build_negated_errors object
      super.add(EXISTS_ERROR, :matching => object)
    end # method build_errors

    def matches_object? object
      require_collection

      raise ArgumentError, 'must be a Hash' if object.nil?

      query_matching(object)
    end # method matches_object?

    def query_matching hsh
      collection.matching(hsh).exists?
    end # method query_matching
  end # module
end # module
