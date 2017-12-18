# lib/bronze/constraints/constraint_builder.rb

require 'bronze/constraints'

constraints_pattern = File.join(
  Bronze.lib_path, 'bronze', 'constraints', '*_constraint.rb'
) # end pattern
SleepingKingStudios::Tools::CoreTools.require_each(constraints_pattern)

module Bronze::Constraints
  # Domain-specific language for defining constraints.
  module ConstraintBuilder
    # Error class for handling invalid constraint params.
    INVALID_CONSTRAINT = Class.new(StandardError)

    # Error class for handling unknown constraint names.
    UNKNOWN_CONSTRAINT = Class.new(StandardError)

    def build_constraint constraint_key, constraint_params
      method_name = :"build_#{constraint_key}_constraint"

      if respond_to?(method_name, true)
        return send(method_name, constraint_params)
      end # if

      raise UNKNOWN_CONSTRAINT,
        %(unrecognized constraint type "#{constraint_key}"),
        caller
    end # method build_constraint

    def build_empty_constraint _
      Bronze::Constraints::EmptyConstraint.new
    end # method build_empty_constraint

    def build_equal_constraint params
      value = require_value(
        params,
        :to,
        :value,
        :message => 'must set a value to equal'
      ) # end require_value

      Bronze::Constraints::EqualityConstraint.new(value)
    end # method build_equal_constraint

    def build_nil_constraint _
      Bronze::Constraints::NilConstraint.new
    end # method build_nil_constraint

    def build_present_constraint _
      Bronze::Constraints::PresenceConstraint.new
    end # method build_present_constraint

    def build_type_constraint params
      value = require_value(
        params,
        :type,
        :value,
        :message => 'must set a type'
      ) # end require_value

      Bronze::Constraints::TypeConstraint.new(value)
    end # method build_equal_constraint

    private

    def require_value params, *keys, message:
      keys.each do |key|
        return params[key] if params.key?(key)
      end # each

      raise INVALID_CONSTRAINT, message, caller(2..-1)
    end # method require_value
  end # module
end # class
