# lib/bronze/operations/operation_chain.rb

require 'bronze/operations'

module Bronze::Operations
  # Operation class representing one or more operation objects to run in
  # sequence.
  #
  # @example
  #   class AppendOperation < Operation
  #     def initialize name
  #       @name = name
  #     end # constructor
  #
  #     def process called_operations = []
  #       called_operations << name
  #     end # method process
  #   end # class
  #
  #   class FailingOperation < AppendOperation
  #     def process called_operations = []
  #       super
  #
  #       @errors.add 'errors.operations.failing'
  #     end # method process
  #   end # class
  #
  #   first  = AppendOperation.new('first')
  #   second = AppendOperation.new('second')
  #   third  = AppendOperation.new('third')
  #   first.then(second).then(third)
  #   #=> #<OperationChain>
  #
  # @example Chaining Operations With #then
  #   operation = AppendOperation.new('first').
  #     then(AppendOperation.new('then operation')).
  #     then { |op| op.result << 'then block' }.
  #     then do |op|
  #       AppendOperation.new('operation block').call(op.result)
  #     end # then
  #   operation.execute.result
  #   #=> ['first', 'then operation', 'then block', 'operation block']
  #   operation.success?
  #   #=> true
  #
  #   operation = AppendOperation.new('first').
  #     then(AppendOperation.new('before failure')).
  #     then(FailingOperation.new('failing operation')).
  #     then(AppendOperation.new('after failure - not called'))
  #   operation.execute.result
  #   #=> ['first', 'before failure', 'failing operation']
  #   operation.success?
  #   #=> false
  #
  # @example Chaining Operations with #else
  #   operation = AppendOperation.new('first').
  #     then(FailingOperation.new('failing operation')).
  #     then(AppendOperation.new('after failure - not called')).
  #     else(AppendOperation.new('rescue failure')).
  #     then(AppendOperation.new('after rescue'))
  #   operation.execute.result
  #   #=> ['first', 'failing operation', 'rescue failure', 'after rescue']
  #   operation.success?
  #   #=> true
  #
  #   operation = AppendOperation.new('first').
  #     then(FailingOperation.new('failing operation')).
  #     then(AppendOperation.new('after failure - not called')).
  #     else(FailingOperation.new('still failing')).
  #     then(AppendOperation.new('after failure - not called'))
  #   operation.execute.result
  #   #=> ['first', 'failing operation', 'still failing']
  #   operation.success?
  #   #=> false
  class OperationChain < Operation
    # @param first_operation [Operation] The first operation in the chain. This
    #   operation will be called with the given arguments when the #call method
    #   of the operation chain is called.
    def initialize first_operation
      @first_operation = first_operation
      @operations      = []
    end # constructor

    # Adds the given block or operation to the end of the operation chain. A
    # block or operation added with #always will always be called after the
    # preceding operation, even if the previous operation failed or is halted.
    #
    # @overload always(operation)
    #   @param operation [Operation] An operation instance to add. The operation
    #     will be called with the #result of the previous operation in the
    #     chain.
    #
    # @overload always(&block)
    #   @yieldparam prev_operation [Operation] The previous operation. If the
    #     block returns an operation instance, that operation will be passed on
    #     to subsequent operations in the chain; otherwise, the previous
    #     operation will be passed instead.
    #
    # @return [OperationChain] The chained operations.
    def always operation = nil, &block
      proc = block_given? ? block : wrap_operation(operation)

      @operations << { :operation => proc, :on => :always }

      self
    end # method always

    # Adds the given block or operation to the end of the operation chain. A
    # block or operation added with #chain will be called after the preceding
    # operation whether it succeeded or failed, but not if the previous
    # operation was halted.
    #
    # @overload chain(operation)
    #   @param operation [Operation] An operation instance to add. The operation
    #     will be called with the #result of the previous operation in the
    #     chain.
    #
    # @overload chain(&block)
    #   @yieldparam prev_operation [Operation] The previous operation. If the
    #     block returns an operation instance, that operation will be passed on
    #     to subsequent operations in the chain; otherwise, the previous
    #     operation will be passed instead.
    #
    # @return [OperationChain] The chained operations.
    def chain operation = nil, &block
      proc = block_given? ? block : wrap_operation(operation)

      @operations << { :operation => proc }

      self
    end # method chain

    # Adds the given block or operation to the end of the operation chain. A
    # block or operation added with #else will be only be called if the previous
    # operation failed and was not halted.
    #
    # @overload else(operation)
    #   @param operation [Operation] An operation instance to add. The operation
    #     will be called with the #result of the previous operation in the
    #     chain.
    #
    # @overload else(&block)
    #   @yieldparam prev_operation [Operation] The previous operation. If the
    #     block returns an operation instance, that operation will be passed on
    #     to subsequent operations in the chain; otherwise, the previous
    #     operation will be passed instead.
    #
    # @return [OperationChain] The chained operations.
    def else operation = nil, &block
      proc = block_given? ? block : wrap_operation(operation)

      @operations << { :operation => proc, :on => :failure }

      self
    end # method then

    # Adds the given block or operation to the end of the operation chain. A
    # block or operation added with #then will be only be called if the previous
    # operation succeeded and was not halted.
    #
    # @overload then(operation)
    #   @param operation [Operation] An operation instance to add. The operation
    #     will be called with the #result of the previous operation in the
    #     chain.
    #
    # @overload then(&block)
    #   @yieldparam prev_operation [Operation] The previous operation. If the
    #     block returns an operation instance, that operation will be passed on
    #     to subsequent operations in the chain; otherwise, the previous
    #     operation will be passed instead.
    #
    # @return [OperationChain] The chained operations.
    def then operation = nil, &block
      proc = block_given? ? block : wrap_operation(operation)

      @operations << { :operation => proc, :on => :success }

      self
    end # method then

    private

    # @!visibility public
    #
    # @overload process(*args)
    #   Private method that handles running the chained operations. The first
    #   operation is called with the parameters passed in from #call or
    #   #execute. Then, each subsequent operation or block in the chain may be
    #   called, based on the status of the last operation. Operations will be
    #   called with one argument (the value of #result on the last operation),
    #   and blocks will be yielded the last operation.
    #
    #   If the last operation was #halted?, only operations added with #always
    #   will be called.
    #
    #   If the last operation was a #success?, then operations added with
    #   #always, #chain, or #then will be called.
    #
    #   If the last operation was a #failure?, then operations added with
    #   #always, #chain, or #else will be called.
    #
    #   Each called operation updates the success and halted state of the chain,
    #   so failed operations can be "rescued" from using #else or #chain.
    #   Likewise, if a block returns an operation instance the returned chain
    #   will update with the success and halted state of the returned operation.
    #
    #   @param args [Array] The arguments passed in to #call or #execute. These
    #
    #   @return [Object] The return value of the last called operation.
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
