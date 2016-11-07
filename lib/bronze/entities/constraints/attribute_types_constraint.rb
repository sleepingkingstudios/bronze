# lib/bronze/entities/constraints/attribute_types_constraint.rb

require 'bronze/constraints/constraint'
require 'bronze/constraints/type_constraint'
require 'bronze/entities/constraints'

module Bronze::Entities::Constraints
  # Constraint validating the types of each entity attribute against the entity
  # definition.
  class AttributeTypesConstraint < Bronze::Constraints::Constraint
    # Error message for objects that do not define attributes.
    MISSING_ATTRIBUTES_ERROR = 'constraints.errors.missing_attributes'.freeze

    # (see Constraint#match)
    def match object
      @defines_attributes = nil

      super
    end # method match

    private

    def attribute_definitions object
      object.class.attributes
    end # method attribute_definitions

    def build_errors object
      errors = super

      if defines_attributes?(object)
        error_type = Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR

        @mismatched_attributes.each do |attr_name, attr_type|
          errors[attr_name].add(error_type, :value => attr_type)
        end # each

        errors
      else
        errors.add(MISSING_ATTRIBUTES_ERROR)
      end # if-else
    end # method build_errors

    def defines_attributes? object
      return @defines_attributes unless @defines_attributes.nil?

      @defines_attributes =
        object.respond_to?(:attributes) && object.class.respond_to?(:attributes)
    end # method defines_attributes?

    def matches_attribute_type? value, metadata
      if value.is_a?(metadata.attribute_type)
        true
      elsif value.nil? && metadata.allow_nil?
        true
      else
        false
      end # if-else
    end # method matches_attribute_types?

    def matches_attribute_types? object
      @mismatched_attributes = {}

      attribute_definitions(object).each do |attr_name, metadata|
        value = object.send(attr_name)

        unless matches_attribute_type?(value, metadata)
          @mismatched_attributes[attr_name] = metadata.attribute_type
        end # unless
      end # all?

      @mismatched_attributes.empty?
    end # method matches_attribute_types?

    def matches_object? object
      defines_attributes?(object) && matches_attribute_types?(object)
    end # method matches_object?

    def negated_matches_object? _object
      raise_invalid_negation caller[1..-1]
    end # method negated_matches_object?
  end # class
end # module
