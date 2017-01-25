# lib/bronze/entities/attributes/transforms/date_transform.rb

require 'bronze/entities/attributes/transforms'

module Bronze::Entities::Attributes::Transforms
  # @api private
  class DateTransform
    Iso8601 = '%F'.freeze

    def self.instance
      @instance ||= new
    end # method instance

    def initialize format = Iso8601
      @format_for_write = format
      @format_for_read  = format_for_write.delete('-')
    end # method initialize

    def denormalize value
      return value if value.is_a?(Date)

      return nil if value.nil? || value.empty?

      Date.strptime(value, format_for_read)
    end # method denormalize

    def format
      @format_for_write
    end # method format

    def normalize value
      return nil if value.nil?

      value.strftime(format_for_write)
    end # method normalize

    private

    attr_reader :format_for_read, :format_for_write
  end # class
end # module
