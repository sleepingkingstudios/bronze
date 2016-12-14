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
      hsh = { :type => metadata.object_type }

      if Array == metadata.object_type
        # hsh[:member_type] = metadata.attribute_type.member_type.object_type
      end # if

      hsh
    end # method build_error

    def defines_attributes? object
      return true if object.respond_to?(:attributes) &&
                     object.class.respond_to?(:attributes)

      errors.add(MISSING_ATTRIBUTES_ERROR)

      false
    end # method defines_attributes?

    def match_array_attribute_type ary, attr_type, nesting
      member_type = attr_type.member_type

      ary.each.with_index do |member, index|
        match_attribute_type member, member_type, nesting.dup.push(index)
      end # each
    end # match_array_attribute_type

    def match_attribute_type value, attribute_type, nesting
      error_type  = Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR
      object_type = attribute_type.object_type

      unless value.is_a?(object_type)
        nested_errors(nesting).add(error_type, :type => object_type) && return
      end # unless

      if Array == object_type
        match_array_attribute_type value, attribute_type, nesting
      elsif Hash == object_type
        match_hash_attribute_type value, attribute_type, nesting
      end # if-elsif
    end # method match_attribute_type

    def match_hash_attribute_type hsh, attr_type, nesting
      error_type  = Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR
      key_type    = attr_type.key_type
      member_type = attr_type.member_type

      hsh.each do |key, value|
        inner_nesting = nesting.dup.push(key)

        unless key.is_a?(key_type)
          nested_errors(inner_nesting).add(error_type, :type => key_type)
        end # unless

        match_attribute_type value, member_type, inner_nesting
      end # each
    end # method match_hash_attribute_type

    def matches_attribute_types? object
      attribute_definitions(object).each do |attr_name, metadata|
        value = object.send(attr_name)

        next if value.nil? && metadata.allow_nil?

        match_attribute_type(value, metadata.attribute_type, [attr_name])
      end # all?

      errors.empty?
    end # method matches_attribute_types?

    def matches_object? object
      defines_attributes?(object) && matches_attribute_types?(object)
    end # method matches_object?

    def negated_matches_object? _object
      raise_invalid_negation caller[1..-1]
    end # method negated_matches_object?

    def nested_errors nesting
      nesting.reduce(errors) { |errors, fragment| errors[fragment] }
    end # method nested_errors
  end # class
end # module
