# lib/bronze/errors/error.rb

require 'bronze/errors'

module Bronze::Errors
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

    # @return [Array] The nesting of the containing errors object.
    attr_reader :nesting

    # @return [Array] Array of additional parameters.
    attr_reader :params

    # @return [Symbol] The error type.
    attr_reader :type
  end # class
end # module