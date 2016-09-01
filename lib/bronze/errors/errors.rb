# lib/bronze/errors/errors.rb

require 'bronze/errors/error'

module Bronze::Errors
  # Class for encapsulating errors encountered during an operation or process.
  class Errors
    def initialize
      @errors = []
    end # constructor

    # Appends an error to the objcet.
    #
    # @param error_type [String, Symbol] The error type.
    # @param error_params [Array] Array of optional error parameters.
    def add error_type, *error_params
      @errors << Error.new(error_type, error_params)
    end # method <<

    # Iterates through the listed errors and yields each to the given block.
    #
    # @yieldparam error [Bronze::Errors::Error] The current error object.
    def each &block
      @errors.each(&block)
    end # each

    # Returns the listed errors.
    #
    # @return [Array] The errors.
    def to_a
      @errors
    end # method to_a
  end # class
end # module
