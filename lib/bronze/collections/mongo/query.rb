# frozen_string_literal: true

require 'forwardable'

require 'bronze/collections/mongo'
require 'bronze/collections/query'

module Bronze::Collections::Mongo
  # Query class that executes against a MongoDB collection.
  class Query < Bronze::Collections::Query
    extend Forwardable

    # @param [Mongo::Collection] collection The MongoDB collection to query
    #   against.
    def initialize(collection)
      @collection = collection
      @selector   = {}
      @limit      = nil
    end

    def_delegators :native_query, :to_a

    # (see Bronze::Collections::Query#count)
    def count
      # TODO: #count is deprecated, but the recommended #count_documents breaks
      #   if the collection is empty - create a support ticket?

      # MongoDB driver does not support limit: 0 queries.
      return 0 if @limit == 0 # rubocop:disable Style/NumericPredicate

      return native_query.count if @limit.nil?

      native_query.count(limit: @limit)
    end

    # (see Bronze::Collections::Query#each)
    def each
      # MongoDB driver does not support limit: 0 queries.
      if @limit == 0 # rubocop:disable Style/NumericPredicate
        return block_given? ? nil : [].each
      end

      return native_query.each unless block_given?

      native_query.each { |item| yield item }
    end

    # (see Bronze::Collections::Query#exists?)
    def exists?
      native_query.any?
    end

    # (see Bronze::Collections::Query#exists?)
    def limit(count)
      dup.tap { |query| query.limit = count }
    end

    # (see Bronze::Collections::Query#matching)
    def matching(hsh)
      unless hsh.is_a?(Hash)
        raise ArgumentError, "invalid selector - #{hsh.inspect}"
      end

      dup.tap { |query| query.selector = selector.merge(hsh) }
    end
    alias_method :where, :matching

    # (see Bronze::Collections::Query#exists?)
    def to_a
      # MongoDB driver does not support limit: 0 queries.
      return [] if @limit == 0 # rubocop:disable Style/NumericPredicate

      super
    end

    protected

    attr_writer :limit

    attr_writer :selector

    private

    attr_reader :collection

    attr_reader :selector

    def native_query
      query = collection.find(selector)

      query = query.limit(@limit) unless @limit.nil?

      query
    end
  end
end
