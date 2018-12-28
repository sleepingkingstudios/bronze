# frozen_string_literal: true

require 'bigdecimal'

require 'bronze/transform'
require 'bronze/transforms/attributes'

module Bronze::Transforms::Attributes
  # Transform class that normalizes a BigDecimal to a string representation.
  class BigDecimalTransform < Bronze::Transform
    # @return [BigDecimalTransform] a memoized instance of BigDecimalTranform.
    def self.instance
      @instance ||= new
    end

    # Converts a normalized BigDecimal (a String) to a BigDecimal instance.
    #
    # @param value [String] The normalized string.
    #
    # @return [BigDecimal] the denormalized instance.
    def denormalize(value)
      return nil if value.nil?

      BigDecimal(value)
    rescue ArgumentError
      BigDecimal('0.0')
    end

    # Converts a BigDecimal to a string representation.
    #
    # @param value [BigDecimal] The BigDecimal to normalize.
    #
    # @return [String] the string representation.
    def normalize(value)
      return nil if value.nil?

      value.to_s
    end
  end
end
