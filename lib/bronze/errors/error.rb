# lib/bronze/errors/error.rb

require 'bronze/errors'

class Bronze::Errors
  # Encapsulates a single error state with standardized type and optional
  # parameters.
  class Error
    # @param nesting [Array] The nesting of the containing errors object.
    # @param type [Symbol] The error type.
    # @param params [Array] Array of additional parameters.
    def initialize nesting, type, params
      @nesting = nesting
      @type    = type
      @params  = params
    end # constructor

    # @return [Boolean] True if the other object is an Error of the same class
    #   and has the same nesting, type, and params.
    def == other
      return false unless other.class == self.class

      type == other.type && nesting == other.nesting && params == other.params
    end # method ==

    # @return [Array] The nesting of the containing errors object.
    attr_reader :nesting

    # @return [Array] Array of additional parameters.
    attr_reader :params

    # @return [Symbol] The error type.
    attr_reader :type

    def with_nesting nesting
      dup.tap { |err| err.nesting = nesting }
    end # method with_nesting

    protected

    attr_writer :nesting
  end # class
end # module
