# frozen_string_literal: true

require 'bronze/transform'
require 'bronze/transforms/attributes'

module Bronze::Transforms::Attributes
  # Transform class that converts a Symbol to a string.
  class SymbolTransform < Bronze::Transform
    # @return [SymbolTransform] a memoized instance of SymbolTransform.
    def self.instance
      @instance ||= new
    end

    # Converts a normalized String to a Symbol.
    #
    # @param value [String] The normalized string.
    #
    # @return [Symbol] the denormalized symbol.
    def denormalize(value)
      return nil if value.nil?

      value.intern
    end

    # Converts a Symbol to a string.
    #
    # @param value [Symbol] The Symbol to normalize.
    #
    # @return [String] the string representation.
    def normalize(value)
      return nil if value.nil?

      value.to_s
    end
  end
end
