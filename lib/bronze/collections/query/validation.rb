# frozen_string_literal: true

require 'bronze/collections/query'

module Bronze::Collections
  class Query
    # Shared validation helpers for Query methods.
    module Validation
      private

      def validate_limit(count)
        return if count.is_a?(Integer) && count.positive?

        raise ArgumentError, 'expected limit to be a positive integer, but ' \
                             "was #{count.inspect}"
      end

      def validate_offset(count)
        return if count.is_a?(Integer) && (count.zero? || count.positive?)

        raise ArgumentError, 'expected offset to be an integer greater than ' \
                             "or equal to zero, but was #{count.inspect}"
      end

      def validate_selector(selector)
        return if selector.is_a?(Hash)

        raise ArgumentError, 'expected selector to be a Hash, but was ' \
                             "#{selector.inspect}"
      end
    end
  end
end
