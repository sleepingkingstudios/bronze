# lib/bronze/operations/operation.rb

require 'bronze/errors'
require 'bronze/operations'

module Bronze::Operations
  # Operations encapsulate a process or procedure of business logic with a
  # consistent architecture and interface.
  #
  # @example Defining a basic operation.
  #   class IncrementOperation < Operation
  #     def process int
  #       int + 1
  #     end # method process
  #   end # class
  #
  #   operation = IncrementOperation.new
  #   operation.call(1)
  #   #=> true
  #   operation.result
  #   #=> 2
  #
  # @example Defining an operation with parameters.
  #   class AddOperation < Operation
  #     def initialize addend
  #       @addend = addend
  #     end # constructor
  #
  #     def process int
  #       int + @addend
  #     end # method process
  #   end # class
  #
  #   operation = AddOperation.new(2)
  #   operation.execute(2)
  #   #=> operation
  #   operation.success?
  #   #=> true
  #   operation.result
  #   #=> 4
  #
  #   operation.execute(4).result
  #   #=> 6
  #
  # @example Operation success and failure.
  #   class IsEvenOperation < Operation
  #     def process int
  #       return true if int.even?
  #
  #       @errors.add 'errors.operations.is_not_even'
  #
  #       false
  #     end # method process
  #   end # class
  #
  #   operation = IsEvenOperation.new
  #   operation.called?
  #   #=> false
  #   operation.success?
  #   #=> false
  #   operation.failure?
  #   #=> false
  #   operation.errors.empty?
  #   #=> true
  #
  #   operation.call(2)
  #   #=> true
  #   operation.called?
  #   #=> true
  #   operation.success?
  #   #=> true
  #   operation.failure?
  #   #=> false
  #   operation.errors.empty?
  #   #=> true
  #
  #   operation.call(3)
  #   #=> false
  #   operation.called?
  #   #=> true
  #   operation.success?
  #   #=> false
  #   operation.failure?
  #   #=> true
  #   operation.errors.empty?
  #   #=> false
  class Operation
    # Error class for handling unimplemented operation methods. Subclasses of
    # Operation must implement these methods.
    class NotImplementedError < StandardError; end

    # @return [Object] The result of the operation, typically the return value
    #   of the #process method. If the operation was not run, returns nil.
    attr_reader :result

    # Chains the given block or operation to the current operation. A block or
    # operation added with #always will always be called after the current
    # operation, even if it failed or is halted.
    #
    # @overload always(operation)
    #   @param operation [Operation] An operation instance to chain after the
    #     current operation. The operation will be called with the value of
    #     #result for the current operation.
    #
    # @overload always(&block)
    #   @yieldparam current_operation [Operation] The current operation. If the
    #     block returns an operation instance, that operation will be passed on
    #     to subsequent operations in the chain; otherwise, the previous
    #     operation will be passed instead.
    #
    # @return [OperationChain] The chained operations.
    def always operation = nil, &block
      chain_operation.always(operation, &block)
    end # method always

    # Wraps the #execute method of the operation and returns true or false to
    # indicate the success of the operation call.
    #
    # @param args [Array] The arguments to the operation. These will be passed
    #   on to #execute.
    #
    # @return [Boolean] True if the operation was called successfully, otherwise
    #   false.
    #
    # @see #execute.
    def call *args
      execute(*args).success?
    end # method run
    alias_method :run, :call

    # @return [Boolean] True if the operation was run, otherwise false.
    def called?
      !!@called
    end # method failure?

    # Chains the given block or operation to the current operation. A block or
    # operation added with #chain will be called after the current operation
    # whether it succeeded or failed, but not if the current operation was
    # halted.
    #
    # @overload chain(operation)
    #   @param operation [Operation] An operation instance to chain after the
    #     current operation. The operation will be called with the value of
    #     #result for the current operation.
    #
    # @overload chain(&block)
    #   @yieldparam current_operation [Operation] The current operation. If the
    #     block returns an operation instance, that operation will be passed on
    #     to subsequent operations in the chain; otherwise, the previous
    #     operation will be passed instead.
    #
    # @return [OperationChain] The chained operations.
    def chain operation = nil, &block
      chain_operation.chain(operation, &block)
    end # method chain

    # Chains the given block or operation to the current operation. A block or
    # operation added with #else will be only be called if the current operation
    # failed and was not halted.
    #
    # @overload chain(operation)
    #   @param operation [Operation] An operation instance to chain after the
    #     current operation. The operation will be called with the value of
    #     #result for the current operation.
    #
    # @overload chain(&block)
    #   @yieldparam current_operation [Operation] The current operation. If the
    #     block returns an operation instance, that operation will be passed on
    #     to subsequent operations in the chain; otherwise, the previous
    #     operation will be passed instead.
    #
    # @return [OperationChain] The chained operations.
    def else operation = nil, &block
      chain_operation.else(operation, &block)
    end # method else

    # Returns the errors from the operation.
    #
    # @return [Array] The operation errors.
    def errors
      @errors || []
    end # method errors

    # Wraps the operation implementation with boilerplate for tracking the
    # status of the operation. The business logic of the operation is handled
    # by #process, which each subclass must implement. In addition to setting
    # the operation result to the return value of #process, calling #execute
    # will clear the operation #errors and reset #called? and #halted? to false,
    # and then update #called? to true unless #process raises an error.
    #
    # @param args [Array] The arguments to the operation. These will be passed
    #   on to the #process method.
    #
    # @return [Operation] The operation.
    def execute *args
      @halted = false
      @called = false
      @errors = Bronze::Errors.new

      @result = process(*args)

      @called = true

      self
    end # method execute

    # @return [Boolean] True if the operation was run but encountered an error,
    #   otherwise false.
    def failure?
      return false unless called?

      !errors.empty?
    end # method failure?

    # Halts the operation, preventing any subsequent operations from running.
    #
    # @return [Operation] The operation.
    def halt!
      @halted = true

      self
    end # method halt!

    # @return [Boolean] True if the operation has been halted, preventing any
    #   chained operations from running.
    def halted?
      !!@halted
    end # method halted?

    # @return [Boolean] True if the operation was run successfully, otherwise
    #   false.
    def success?
      return false unless called?

      errors.empty?
    end # method success?

    # Chains the given block or operation to the current operation.  A block or
    # operation added with #then will be only be called if the current
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
      chain_operation.then(operation, &block)
    end # method then

    protected

    def chain_operation
      OperationChain.new(self)
    end # method chain_operation

    # @!visibility public
    #
    # @overload process(*args)
    #   Private method that handles the actual implementation of running the
    #   operation. Subclasses of Operation should override this method to
    #   implement their functionality.
    #
    #   @param args [Array] The arguments passed in to #call or #execute.
    #
    #   @return [Object] The return value. Operation#result will return this
    #     value.
    #
    #   @raise NotImplementedError If the subclass has not reimplemented the
    #     #process method.
    def process *_args
      raise NotImplementedError,
        "#{self.class.name} does not implement :process",
        caller[1..-1]
    end # method process
  end # class
end # module
