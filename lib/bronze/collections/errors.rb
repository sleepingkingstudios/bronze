# frozen_string_literal: true

require 'bronze/collections'

module Bronze::Collections
  # Defines error messages when querying or updating a collection.
  module Errors
    # Error message when trying to insert an empty data hash into a collection.
    DATA_EMPTY = 'bronze.collections.errors.data_empty'

    # Error message when trying to insert invalid data into a collection, such
    # as a non-Hash object.
    DATA_INVALID = 'bronze.collections.errors.data_invalid'

    # Error message when trying to insert nil into a collection.
    DATA_MISSING = 'bronze.collections.errors.data_missing'

    class << self
      # @return [String] the error message when trying to insert an empty data
      #   hash into a collection.
      def data_empty
        DATA_EMPTY
      end

      # @return [String] the error message when trying to insert nil into a
      #   collection.
      def data_missing
        DATA_MISSING
      end

      # @return [String] the error message when trying to insert invalid data
      #   into a collection.
      def data_invalid
        DATA_INVALID
      end
    end
  end
end
