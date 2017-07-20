# lib/bronze/operations/identity_operation.rb

require 'bronze/operations/operation'

module Bronze::Operations
  # A basic operation that accepts a value and returns the value as the
  # operation result.
  class IdentityOperation < Bronze::Operations::Operation
    # Accepts and returns a value.
    #
    # @param value [Object] The value to return.
    #
    # @return [Object] The given value.
    def process value
      value
    end # method process
  end # class
end # module
