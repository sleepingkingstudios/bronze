# lib/bronze/constraints/constraint.rb

require 'bronze/constraints'
require 'bronze/errors/errors'

module Bronze::Constraints
  # Constraints encapsulate a single expectation that an object may or may not
  # match. Constraints can be used individually or aggregated into a contract.
  class Constraint
    # Error class for handling unimplemented constraint methods. Subclasses of
    # Constraint must implement these methods.
    class NotImplementedError < StandardError; end

    def match object
      return [true, []] if matches_object? object

      [false, build_errors(object)]
    end # method match

    private

    def build_errors _object
      Bronze::Errors::Errors.new
    end # method build_errors

    def matches_object? _object
      raise NotImplementedError,
        "#{self.class.name} does not implement :matches_object?",
        caller
    end # method matches_object?
  end # class
end # module
