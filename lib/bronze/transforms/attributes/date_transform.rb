# frozen_string_literal: true

require 'date'

require 'bronze/transforms/attributes'
require 'bronze/transforms/transform'

module Bronze::Transforms::Attributes
  # Transform class that normalizes a Date to a formatted string representation.
  class DateTransform < Bronze::Transforms::Transform
    # Format string for ISO 8601 date format. Equivalent to YYYY-MM-DD.
    ISO_8601 = '%F'

    # @return [DateTransform] a memoized instance of DateTransform.
    def self.instance
      @instance ||= new
    end

    # @param format [String] The format string used to normalize and denormalize
    #   dates. The default is ISO 8601 format.
    def initialize(format = ISO_8601)
      @format = format
    end

    # @return [String] the format string.
    attr_reader :format

    # Converts a formatted Date string to a Date instance.
    #
    # @param value [String] The normalized string.
    #
    # @return [Date] the parsed date.
    def denormalize(value)
      return value if value.is_a?(Date)

      return nil if value.nil? || value.empty?

      Date.strptime(value, read_format)
    end

    # Converts a Date to a formatted string.
    #
    # @param value [Date] The Date to format.
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
