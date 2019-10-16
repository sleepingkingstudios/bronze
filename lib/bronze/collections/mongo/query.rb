# frozen_string_literal: true

require 'forwardable'

require 'bronze/collections/mongo'
require 'bronze/collections/null_query'
require 'bronze/collections/query'
require 'bronze/collections/query/validation'
require 'bronze/collections/simple/ordering'

module Bronze::Collections::Mongo
  # Query class that executes against a MongoDB collection.
  class Query < Bronze::Collections::Query
    extend Forwardable

    include Bronze::Collections::Query::Validation
    include Bronze::Collections::Simple::Ordering

    # @param [Mongo::Collection] collection The MongoDB collection to query
    #   against.
    def initialize(collection, transform: nil)
      @collection = collection
      @transform  = transform
      @selector   = {}
      @ordering   = nil
      @limit      = nil
    end

    def_delegators :native_query, :to_a

    # (see Bronze::Collections::Query#count)
    def count
      # TODO: #count is deprecated, but the recommended #count_documents breaks
      #   if the collection is empty - create a support ticket?
      native_query.count(limit: @limit, skip: @offset)
    end

    # (see Bronze::Collections::Query#each)
    def each
      return enum_for(:each_with_transform) unless block_given?

      each_with_transform { |item| yield item }
    end

    # (see Bronze::Collections::Query#exists?)
    def exists?
      native_query.any?
    end

    # (see Bronze::Collections::Query#exists?)
    def limit(count)
      validate_limit(count)

      dup.tap { |query| query.limit = count }
    end

    # (see Bronze::Collections::Query#matching)
    def matching(hsh)
      validate_selector(hsh)

      dup.tap { |query| query.selector = selector.merge(hsh) }
    end
    alias_method :where, :matching

    # (see Bronze::Collections::Query#none)
    def none
      Bronze::Collections::NullQuery.new
    end

    # (see Bronze::Collections::Query#offset)
    def offset(count)
      validate_offset(count)

      dup.tap { |query| query.offset = count }
    end
    alias_method :skip, :offset

    # (see Bronze::Collections::Query#order)
    def order(*attributes)
      dup.tap { |query| query.ordering = generate_ordering(attributes) }
    end

    # (see Bronze::Collections::Query#to-a)
    def to_a
      # MongoDB driver does not support limit: 0 queries.
      return [] if @limit == 0 # rubocop:disable Style/NumericPredicate

      super
    end

    protected

    attr_writer :limit

    attr_writer :offset

    attr_writer :ordering

    attr_writer :selector

    private

    attr_reader :collection

    attr_reader :ordering

    attr_reader :selector

    def each_with_transform
      enumerator = native_query.each

      if transform
        enumerator = enumerator.map { |item| transform.denormalize(item) }
      end

      enumerator.each { |item| yield item }
    end

    def native_query
      query = collection.find(selector)

      query = query.sort(@ordering) unless @ordering.nil?

      query = query.limit(@limit) unless @limit.nil?

      query = query.skip(@offset) unless @offset.nil?

      query
    end

    def generate_ordering(attributes)
      Hash[
        super.map do |key, value|
          [key, value == :asc ? 1 : -1]
        end
      ]
    end
  end
end
