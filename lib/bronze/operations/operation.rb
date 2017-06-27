# lib/bronze/operations/operation.rb

require 'bronze/errors'
require 'bronze/operations'

module Bronze::Operations
  # Operations encapsulate a process or procedure of business logic with a
  # consistent architecture and interface.
  class Operation
    # Error class for handling unimplemented operation methods. Subclasses of
    # Operation must implement these methods.
    class NotImplementedError < StandardError; end

    # @return [Object] The result of the operation, typically the return value
    #   of the #process method. If the operation was not run, returns nil.
    attr_reader :result

    # Chains the given block or operation to the current operation, so that when
    # the current operation is called (whether the operation succeeds or fails,
    # even if the operation is halted), it will call the block or operation
    # with the results of the current operation.
    #
    # @param operation [Operation] An operation instance to chain after the
    #   current operation. The operation will be called with the value of
    #   #result for the current operation.
    #
    # @yieldparam current_operation [Operation] The current operation is passed
    #   to the block, allowing the block to grab the result (or any other
    #   property) of the operation. If the block returns an operation instance,
    #   that operation is passed on to the subsequent item in the chain (if
    #   any); otherwise the current operation is passed on.
    #
    # @return [OperationChain] The chained operations.
    def always operation = nil, &block
      chain_operation.always(operation, &block)
    end # method always

    # Executes the operation and returns true or false to indicate the success
    # of the operation call.
    #
    # @param args [Array] The arguments to the operation. These will be passed
    #   on to #process.
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

    # Chains the given block or operation to the current operation, so that when
    # the current operation is called (whether the operation succeeds or fails,
    # but not if the operation is halted), it will call the block or operation
    # with the results of the current operation.
    #
    # @param operation [Operation] An operation instance to chain after the
    #   current operation. The operation will be called with the value of
    #   #result for the current operation.
    #
    # @yieldparam current_operation [Operation] The current operation is passed
    #   to the block, allowing the block to grab the result (or any other
    #   property) of the operation. If the block returns an operation instance,
    #   that operation is passed on to the subsequent item in the chain (if
    #   any); otherwise the current operation is passed on.
    #
    # @return [OperationChain] The chained operations.
    def chain operation = nil, &block
      chain_operation.chain(operation, &block)
    end # method chain

    # Chains the given block or operation to the current operation, so that when
    # the current operation is unsuccessfully called (i.e. #failure? responds
    # true, typically meaning that there are one or more errors), it will call
    # the block or operation with the results of the current operation.
    #
    # @param operation [Operation] An operation instance to chain after the
    #   current operation. The operation will be called with the value of
    #   #result for the current operation.
    #
    # @yieldparam current_operation [Operation] The current operation is passed
    #   to the block, allowing the block to grab the result (or any other
    #   property) of the operation. If the block returns an operation instance,
    #   that operation is passed on to the subsequent item in the chain (if
    #   any); otherwise the current operation is passed on.
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
    # by #process, which each subclass must implement.
    #
    # @param args [Array] The arguments to the operation. These will be passed
    #   on to #process.
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

    # Chains the given block or operation to the current operation, so that when
    # the current operation is successfully called (i.e. #success? responds
    # true, typically meaning that there are no errors), it will call the block
    # or operation with the results of the current operation.
    #
    # @param operation [Operation] An operation instance to chain after the
    #   current operation. The operation will be called with the value of
    #   #result for the current operation.
    #
    # @yieldparam current_operation [Operation] The current operation is passed
    #   to the block, allowing the block to grab the result (or any other
    #   property) of the operation. If the block returns an operation instance,
    #   that operation is passed on to the subsequent item in the chain (if
    #   any); otherwise the current operation is passed on.
    #
    # @return [OperationChain] The chained operations.
    def then operation = nil, &block
      chain_operation.then(operation, &block)
    end # method then

    protected

    def chain_operation
      OperationChain.new(self)
    end # method chain_operation

    def process *_args
      raise NotImplementedError,
        "#{self.class.name} does not implement :process",
        caller[1..-1]
    end # method process
  end # class
end # module
