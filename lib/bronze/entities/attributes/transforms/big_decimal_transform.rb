# lib/bronze/entities/attributes/transforms/big_decimal_transform.rb

require 'bigdecimal'

require 'bronze/entities/attributes/transforms'

module Bronze::Entities::Attributes::Transforms
  # @api private
  class BigDecimalTransform
    def self.instance
      @instance ||= new
    end # method instance

    def denormalize value
      return nil if value.nil?

      BigDecimal.new(value)
    rescue ArgumentError
      BigDecimal.new('0.0')
    end # method denormalize

    def normalize value
      return nil if value.nil?

      value.to_s
    end # method normalize
  end # class
end # module
