# lib/bronze/entities/attributes/transforms/time_transform.rb

require 'bronze/entities/attributes/transforms'

module Bronze::Entities::Attributes::Transforms
  # @api private
  class TimeTransform
    def self.instance
      @instance ||= new
    end # method instance

    def denormalize value
      return nil if value.nil?

      Time.at(value)
    end # method denormalize

    def normalize value
      return nil if value.nil?

      value.to_i
    end # method normalize
  end # class
end # module
