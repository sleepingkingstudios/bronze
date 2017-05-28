# lib/bronze/entities/constraints/uniqueness_constraint.rb

require 'bronze/collections/constraints/exists_constraint'
require 'bronze/constraints/constraint'
require 'bronze/entities/constraints'

module Bronze::Entities::Constraints
  # Constraint evaluating the uniqueness of an entity within a collection.
  class UniquenessConstraint < Bronze::Collections::Constraints::ExistsConstraint # rubocop:disable Metrics/LineLength
    # Error message for objects that match the constraint.
    NOT_UNIQUE_ERROR =
      'constraints.errors.messages.not_unique'.freeze

    # @param attributes [Array[String, Symbol]] The names of attributes that
    #   must match the entity for the collection to include a matching object.
    def initialize *attributes
      @attributes = attributes
    end # constructor

    attr_reader :attributes

    private

    def attribute_values entity
      attributes.each.with_object({}) do |attribute, hsh|
        hsh[attribute.intern] = entity.send(attribute)
      end # each
    end # attribute_values

    def build_errors object
      errors.add(NOT_UNIQUE_ERROR, :matching => attribute_values(object))
    end # method build_errors

    def matches_object? object
      require_collection

      raise ArgumentError, 'must be a Hash' if object.nil?

      hsh = attribute_values(object).merge :id => { :__ne => object.id }

      !query_matching(hsh)
    end # method matches_object?

    def negated_matches_object? _object
      raise_invalid_negation caller[1..-1]
    end # method negated_matches_object?
  end # module
end # module
