# lib/bronze/constraints/constraint.rb

require 'bronze/constraints'
require 'bronze/errors/errors'

module Bronze::Constraints
  # Constraints encapsulate a single expectation that an object may or may not
  # match. Constraints can be used individually or aggregated into a contract.
  class Constraint
    # Error class for handling constraints that do not support negated matching.
    class InvalidNegationError < StandardError; end

    # Error class for handling unimplemented constraint methods. Subclasses of
    # Constraint must implement these methods.
    class NotImplementedError < StandardError; end

    def match object, passed_errors = nil
      @errors = passed_errors

      return [true, errors] if matches_object? object

      [false, build_errors(object)]
    end # method match

    def negated_match object, passed_errors = nil
      @errors = passed_errors

      return [true, errors] if negated_matches_object? object

      [false, build_negated_errors(object)]
    end # method negated_match
    alias_method :does_not_match, :negated_match

    private

    def build_errors _object
      errors
    end # method build_errors

    def build_negated_errors _object
      errors
    end # method build_errors

    def errors
      @errors ||= Bronze::Errors::Errors.new
    end # method errors

    def matches_object? _object
      raise NotImplementedError,
        "#{self.class.name} does not implement :matches_object?",
        caller
    end # method matches_object?

    def negated_matches_object? object
      !matches_object?(object)
    end # method negated_matches_object?

    def raise_invalid_negation call_stack = nil
      raise InvalidNegationError,
        "#{self.class.name} constraints do not support negated matching",
        call_stack || caller[1..-1]
    end # method raise_invalid_negation
  end # class
end # module
