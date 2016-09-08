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

    # Wraps the operation implementation with boilerplate for tracking the
    # status of the operation. The business logic of the operation is handled
    # by #process, which each subclass must implement.
    #
    # @param args [Array] The arguments to the operation. These will be passed
    #   on to #process.
    def call *args
      @called = false
      @errors = Bronze::Errors::Errors.new

      process(*args)

      @called = true

      success?
    end # method run
    alias_method :run, :call

    # Returns the errors from the operation.
    #
    # @return [Array] The operation errors.
    def errors
      @errors || []
    end # method errors

    # @return [Boolean] True if the operation was run but encountered an error,
    #   otherwise false.
    def failure?
      (@called && !@errors.empty?) || false
    end # method failure?

    # @return [Boolean] True if the operation was run successfully, otherwise
    #   false.
    def success?
      (@called && @errors.empty?) || false
    end # method success?

    protected

    def process *_args
      raise NotImplementedError,
        "#{self.class.name} does not implement :process",
        caller[1..-1]
    end # method process
  end # class
end # module
