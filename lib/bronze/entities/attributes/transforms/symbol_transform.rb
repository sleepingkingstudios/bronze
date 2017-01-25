# lib/bronze/entities/attributes/transforms/symbol_transform.rb

require 'bronze/entities/attributes/transforms'

module Bronze::Entities::Attributes::Transforms
  # @api private
  class SymbolTransform
    def self.instance
      @instance ||= new
    end # method instance

    def denormalize value
      return nil if value.nil?

      value.intern
    end # method denormalize

    def normalize value
      return nil if value.nil?

      value.to_s
    end # method normalize
  end # class
end # module
