# lib/bronze/constraints/contextual_constraint.rb

require 'bronze/constraints'

module Bronze::Constraints
  # Wrapper object that encapsulates a constraint object and additional
  # metadata, such as a property name and conditionals.
  class ContextualConstraint < Bronze::Constraints::Constraint
    # @param constraint [Bronze::Constraints::Constraint] The wrapped constraint
    #   object.
    # @param negated [Boolean] If true, the constraint will fail on a matching
    #   object and pass on an object that does not match.
    # @param property [String, Symbol] The name of the property to match. If a
    #   property name is given, the constraint will be matched against the value
    #   of the property on the object; otherwise, the constraint will be matched
    #   against the object itself.
    def initialize constraint, negated: false, property: nil, **kwargs
      @constraint = constraint
      @negated    = negated
      @property   = property

      @if_condition     = kwargs[:if]     if kwargs[:if].is_a?(Proc)
      @unless_condition = kwargs[:unless] if kwargs[:unless].is_a?(Proc)
    end # constructor

    # @return [Bronze::Constraints::Constraint] The wrapped constraint object.
    attr_reader :constraint

    # @return [Proc] The constraint will automatically pass for all objects
    #   matching this condition.
    attr_reader :if_condition

    # @return [Boolean] If true, the constraint will fail on a matching object
    #   and pass on an object that does not match.
    attr_reader :negated

    # @return [String, Symbol] The name of the property to match.
    attr_reader :property

    # @return [Proc] The constraint will automatically pass for all objects
    #   that do not match this condition.
    attr_reader :unless_condition

    # @return [Boolean] If true, the constraint will fail on a matching object
    #   and pass on an object that does not match.
    def negated?
      !!@negated
    end # method negated?

    private

    def apply_with_arity proc, object
      if proc.arity >= 2
        object.instance_exec(object, property, &proc)
      elsif proc.arity == 1
        object.instance_exec(object, &proc)
      else
        object.instance_exec(&proc)
      end # if-else
    end # method apply_with_arity

    def build_errors _object
      @errors
    end # method build_errors

    def build_negated_errors _object
      @errors
    end # method build_errors

    def extract_value object
      return object unless property

      return object.send(property) if object.respond_to?(property)

      object[property] if object.respond_to?(:[])
    end # method extract_value

    def matches_object? object
      @errors = []

      return true, @errors if skip?(object)

      value        = extract_value object
      match_method = negated? ? :negated_match : :match

      result, @errors = constraint.send(match_method, value)

      result
    end # method matches_object?

    def negated_matches_object? object
      @errors = []

      return true, @errors if skip?(object)

      value        = extract_value object
      match_method = negated? ? :match : :negated_match

      result, @errors = constraint.send(match_method, value)

      result
    end # method matches_object?

    def skip? object
      if @if_condition
        return true unless apply_with_arity(@if_condition, object)
      elsif @unless_condition
        return true if apply_with_arity(@unless_condition, object)
      end # if-elsif

      false
    end # method skip?
  end # class
end # module
