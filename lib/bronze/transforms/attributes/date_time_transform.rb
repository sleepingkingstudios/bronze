# frozen_string_literal: true

require 'date'

require 'bronze/transform'
require 'bronze/transforms/attributes'

module Bronze::Transforms::Attributes
  # Transform class that normalizes a DateTime to a formatted string
  # representation.
  class DateTimeTransform < Bronze::Transform
    # Format string for ISO 8601 date+time format. Equivalent to
    # YYYY-MM-DDTHH:MM:SS+ZZZZ.
    ISO_8601 = '%FT%T%z'

    # @return [DateTimeTransform] a memoized instance of DateTimeTransform.
    def self.instance
      @instance ||= new
    end

    # @param format [String] The format string used to normalize and denormalize
    #   date times. The default is ISO 8601 format.
    def initialize(format = ISO_8601)
      @format = format
    end

    # @return [String] the format string.
    attr_reader :format

    # Converts a formatted DateTime string to a Date instance.
    #
    # @param value [String] The normalized string.
    #
    # @return [DateTime] the parsed date+time.
    def denormalize(value)
      return value if value.is_a?(DateTime)

      return nil if value.nil? || value.empty?

      DateTime.strptime(value, read_format)
    end

    # Converts a DateTime to a formatted string.
    #
    # @param value [DateTime] The DateTime to format.
    #
    # @return [String] the formatted string.
    def normalize(value)
      return nil if value.nil?

      value.strftime(format)
    end

    private

    def read_format
      @read_format ||= format.gsub('%-', '%')
    end
  end
end
