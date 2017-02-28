# lib/bronze/operations/null_operation.rb

require 'bronze/operations/operation'

module Bronze::Operations
  # Operation that does nothing when called.
  class NullOperation < Bronze::Operations::Operation
    private

    def process; end
  end # class
end # module
