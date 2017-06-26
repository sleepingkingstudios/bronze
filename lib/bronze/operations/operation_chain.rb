# lib/bronze/operations/operation_chain.rb

require 'bronze/operations'

module Bronze::Operations
  # Operation class representing one or more operation objects to run in
  # sequence.
  class OperationChain < Operation
    def initialize first_operation
      @first_operation = first_operation
      @operations      = []
    end # constructor

    def else operation = nil, &block
      proc = block_given? ? block : wrap_operation(operation)

      @operations << { :operation => proc, :on => :failure }

      self
    end # method then

    def process *args
      @called = true

      @first_operation.execute(*args)

      last_operation =
        @operations.reduce(@first_operation) \
        do |prev_operation, chained_operation|
          run_operation(prev_operation, chained_operation)
        end # reduce

      @errors = last_operation.errors

      last_operation.result
    end # method process

    def then operation = nil, &block
      proc = block_given? ? block : wrap_operation(operation)

      @operations << { :operation => proc, :on => :success }

      self
    end # method then

    private

    def run_operation prev_operation, chained_operation
      if chained_operation[:on] == :success && !prev_operation.success?
        return prev_operation
      end # if

      if chained_operation[:on] == :failure && !prev_operation.failure?
        return prev_operation
      end # if

      output = chained_operation.fetch(:operation).call(prev_operation)

      output.is_a?(Bronze::Operations::Operation) ? output : prev_operation
    end # method run_operation

    def wrap_operation operation
      ->(last_operation) { operation.execute(last_operation.result) }
    end # method wrap_operation
  end # class
end # module
