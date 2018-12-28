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
    def match object, passed_errors = nil
      @defines_attributes = nil

      super
    end # method match

    private

    def attribute_definitions object
      object.class.attributes
    end # method attribute_definitions

    def build_error_params metadata
      hsh = { :type => metadata.type }

      if Array == metadata.type
        hsh[:member_type] = metadata.type
      end # if

      hsh
    end # method build_error

    def defines_attributes? object
      return true if object.respond_to?(:attributes) &&
                     object.class.respond_to?(:attributes)

      errors.add(MISSING_ATTRIBUTES_ERROR)

      false
    end # method defines_attributes?

    def match_attribute_type value, attribute_type, nesting
      error_type = Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR

      return if value.is_a?(attribute_type)

      errors.dig(*nesting).add(error_type, :type => attribute_type)
    end # method match_attribute_type

    def matches_attribute_types? object
      attribute_definitions(object).each do |attr_name, metadata|
        value = object.send(attr_name)

        next matches_nil?(attr_name, metadata) if value.nil?

        match_attribute_type(value, metadata.type, [attr_name])
      end # all?

      errors.empty?
    end # method matches_attribute_types?

    def matches_nil? attr_name, metadata
      return if metadata.allow_nil?

      errors[attr_name].
        add(Bronze::Constraints::PresenceConstraint::EMPTY_ERROR)
    end # method matches_nil?

    def matches_object? object
      defines_attributes?(object) && matches_attribute_types?(object)
    end # method matches_object?

    def negated_matches_object? _object
      raise_invalid_negation caller(1..-1)
    end # method negated_matches_object?
  end # class
end # module
