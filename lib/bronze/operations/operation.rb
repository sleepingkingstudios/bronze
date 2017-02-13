# lib/bronze/operations/operation.rb

require 'bronze/errors/errors'
require 'bronze/operations'

module Bronze::Operations
  # Operations encapsulate a process or procedure of business logic with a
  # consistent architecture and interface.
  class Operation
    # Error class for handling unimplemented operation methods. Subclasses of
    # Operation must implement these methods.
    class NotImplementedError < StandardError; end

    attr_reader :failure_message

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

    # If the operation was run but encountered an error, yields the operation to
    # the block and returns either the result (if the result is an operation) or
    # the operation. Otherwise, returns the operation.
    #
    # @param expected_message [String] The expected failure message. If a
    #   message is given, only failures wth the specified message will call the
    #   block.
    #
    # @yieldparam operation [Operation] The current operation.
    #
    # @return [Operation] The result of the block, or the current operation.
    def else expected_message = nil, &block
      return self unless failure?

      return self if expected_message && expected_message != failure_message

      op = block.call(self)

      op.is_a?(Operation) ? op : self
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
      @called = false
      @errors = Bronze::Errors::Errors.new
      @failure_message = nil

      process(*args)

      @called = true

      self
    end # method execute

    # @return [Boolean] True if the operation was run but encountered an error,
    #   otherwise false.
    def failure?
      return false unless @called

      !@errors.empty? || !(@failure_message.nil? || @failure_message.empty?)
    end # method failure?

    # @return [Boolean] True if the operation was run successfully, otherwise
    #   false.
    def success?
      return false unless @called

      @errors.empty? && (@failure_message.nil? || @failure_message.empty?)
    end # method success?

    # If the operation was run successfully, yields the operation to the block
    # and returns either the result (if the result is an operation) or the
    # operation. Otherwise, returns the operation.
    #
    # @yieldparam operation [Operation] The current operation.
    #
    # @return [Operation] The result of the block, or the current operation.
    def then &block
      return self unless success?

      op = block.call(self)

      op.is_a?(Operation) ? op : self
    end # method then

    protected

    attr_writer :failure_message

    def process *_args
      raise NotImplementedError,
        "#{self.class.name} does not implement :process",
        caller[1..-1]
    end # method process
  end # class
end # module
