# frozen_string_literal: true

require 'date'

require 'bronze/transforms/attributes'
require 'bronze/transforms/transform'

module Bronze::Transforms::Attributes
  # Transform class that converts a Time to an integer timestamp.
  class TimeTransform < Bronze::Transforms::Transform
    # @return [TimeTransform] a memoized instance of TimeTransform.
    def self.instance
      @instance ||= new
    end

    # Converts an integer timestamp to a Time.
    #
    # @param value [Integer] The integer timestamp.
    #
    # @return [Time] the Time corresponding to the timestamp.
    def denormalize(value)
      return nil if value.nil?

      Time.at(value)
    end

    # Converts a Time to an integer timestamp.
    #
    # @param value [Time] The Time to normalize.
    #
    # @return [Integer] the integer timestamp.
    def normalize(value)
      return nil if value.nil?

      value.to_i
    end
  end
end
