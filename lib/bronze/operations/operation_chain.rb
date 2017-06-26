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

    def always operation = nil, &block
      proc = block_given? ? block : wrap_operation(operation)

      @operations << { :operation => proc, :on => :always }

      self
    end # method always

    def chain operation = nil, &block
      proc = block_given? ? block : wrap_operation(operation)

      @operations << { :operation => proc }

      self
    end # method chain

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
      @halted = last_operation.halted?

      last_operation.result
    end # method process

    def then operation = nil, &block
      proc = block_given? ? block : wrap_operation(operation)

      @operations << { :operation => proc, :on => :success }

      self
    end # method then

    private

    def run_operation prev_operation, chained_operation
      unless run_operation?(prev_operation, :on => chained_operation[:on])
        return prev_operation
      end # unless

      output = chained_operation.fetch(:operation).call(prev_operation)

      output.is_a?(Bronze::Operations::Operation) ? output : prev_operation
    end # method run_operation

    # rubocop:disable Metrics/CyclomaticComplexity
    def run_operation? prev_operation, on:
      return false if on != :always  && prev_operation.halted?

      return false if on == :success && !prev_operation.success?

      return false if on == :failure && !prev_operation.failure?

      true
    end # method run_operation?
    # rubocop:enable Metrics/CyclomaticComplexity

    def wrap_operation operation
      ->(last_operation) { operation.execute(last_operation.result) }
    end # method wrap_operation
  end # class
end # module
