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

    # @return [Boolean] true if any data matches the query; otherwise false.
    def exists?
      !limit(1).count.zero?
    end

    # @overload limit(_count)
    #   Returns a query that returns at most the specified number of results.
    #   The existing query is unchanged.
    #
    #   @param count [Index] The maximum number of items to return.
    #
    #   @return [Query] the generated Query.
    #
    #   @raise Bronze::NotImplementedError unless overriden by a Query subclass.
    def limit(_count)
      raise Bronze::NotImplementedError.new(self, :limit)
    end

    # @overload matching(selector)
    #   Returns a query that filters the data using the given selector. The
    #   existing query is unchanged.
    #
    #   @param selector [Hash] The criteria used to filter the data.
    #
    #   @return [Query] the generated Query.
    #
    #   @raise Bronze::NotImplementedError unless overriden by a Query subclass.
    def matching(_selector)
      raise Bronze::NotImplementedError.new(self, :matching)
    end
    alias_method :where, :matching

    # @return [Array] the matching data as an Array.
    #
    # @raise Bronze::NotImplementedError unless overriden by a Query subclass.
    def to_a
      each.to_a
    end
  end
end
