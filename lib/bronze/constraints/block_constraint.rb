# lib/bronze/constraints/block_constraint.rb

require 'bronze/constraints/constraint'

module Bronze::Constraints
  # Constraint that matches only nil.
  class BlockConstraint < Constraint
    # Error message for objects that do not match the constraint.
    NOT_SATISFY_BLOCK_ERROR =
      'constraints.errors.messages.not_satisfy_block'.freeze

    # Error message for objects that match the constraint.
    SATISFY_BLOCK_ERROR =
      'constraints.errors.messages.satisfy_block'.freeze

    def initialize error = nil, &block
      @error = error
      @block = block
    end # constructor

    private

    def build_errors _object
      super.add(@error || NOT_SATISFY_BLOCK_ERROR)
    end # method build_errors

    def build_negated_errors _object
      super.add(@error || SATISFY_BLOCK_ERROR)
    end # method build_errors

    def matches_object? object
      @block.call(object)
    end # method matches_object?
  end # class
end # module
