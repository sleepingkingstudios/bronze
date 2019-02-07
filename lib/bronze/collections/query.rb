# frozen_string_literal: true

require 'bronze/collections'
require 'bronze/not_implemented_error'

module Bronze::Collections
  # Abstract class defining the interface for collection queries.
  class Query
    # @return [Integer] the number of matching items.
    #
    # @raise Bronze::NotImplementedError unless overriden by a Query subclass.
    def count
      raise Bronze::NotImplementedError.new(self, :count)
    end

    # @overload each
    #   @return [Enumerator] an enumerator that iterates over the matching data.
    #
    # @overload each(&block)
    #   Iterates over the matching data, yielding each item to the block.
    #
    #   @yieldparam item [Hash] the current matching item.
    #
    # @raise Bronze::NotImplementedError unless overriden by a Query subclass.
    def each
      raise Bronze::NotImplementedError.new(self, :each)
    end

    # @return [Array] the matching data as an Array.
    #
    # @raise Bronze::NotImplementedError unless overriden by a Query subclass.
    def to_a
      each.to_a
    end
  end
end
