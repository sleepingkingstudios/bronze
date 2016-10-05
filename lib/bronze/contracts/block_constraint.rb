# lib/bronze/contracts/block_constraint.rb

require 'bronze/contracts/constraint'

module Bronze::Contracts
  # Constraint that matches only nil.
  class BlockConstraint < Constraint
    # Error message for objects that do not match the constraint.
    NOT_SATISFY_BLOCK_ERROR = :not_nil

    def initialize &block
      @block = block
    end # constructor

    private

    def build_errors _object
      super.add(NOT_SATISFY_BLOCK_ERROR)
    end # method build_errors

    def matches_object? object
      @block.call(object)
    end # method matches_object?
  end # class
end # module
