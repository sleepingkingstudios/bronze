# frozen_string_literal: true

require 'bronze/collections/null_query'
require 'bronze/collections/query'
require 'bronze/collections/query/validation'
require 'bronze/collections/simple'
require 'bronze/collections/simple/ordering'

module Bronze::Collections::Simple
  # Query class that filters in-memory data in an Array of Hashes format.
  class Query < Bronze::Collections::Query # rubocop:disable Metrics/ClassLength
    include Bronze::Collections::Query::Validation
    include Bronze::Collections::Simple::Ordering

    UNDEFINED = Object.new
    private_constant :UNDEFINED

    # @param [Array<Hash>] data The data to query against.
    # @return [Bronze::Transform] the transform used to convert queried data to
    #   a usable form.
    def initialize(data, transform: nil)
      @data         = data
      @transform    = transform
      @filters      = []
      @max_results  = nil
      @skip_results = nil
      @ordering     = nil
    end

    # (see Bronze::Collections::Query#count)
    def count
      each.reduce(0) { |count, _| count + 1 }
    end

    # (see Bronze::Collections::Query#each)
    def each
      return enum_for(:matching_data) unless block_given?

      matching_data { |item| yield item }
    end

    # (see Bronze::Collections::Query#limit)
    def limit(count)
      validate_limit(count)

      dup.with_limit(count)
    end

    # (see Bronze::Collections::Query#matching)
    def matching(selector)
      validate_selector(selector)

      dup.with_filters(selector)
    end
    alias_method :where, :matching

    # (see Bronze::Collections::Query#none)
    def none
      Bronze::Collections::NullQuery.new
    end

    # (see Bronze::Collections::Query#offset)
    def offset(count)
      validate_offset(count)

      dup.with_offset(count)
    end
    alias_method :skip, :offset

    # (see Bronze::Collections::Query#order)
    def order(*attributes)
      dup.with_ordering(attributes)
    end

    protected

    attr_writer :filters

    def with_limit(count)
      @max_results = count

      self
    end

    def with_filters(selector)
      parse_selector(selector, [])

      self
    end

    def with_offset(count)
      @skip_results = count

      self
    end

    def with_ordering(attributes)
      @ordering = generate_ordering(attributes)

      self
    end

    private

    attr_reader :data

    attr_reader :filters

    attr_reader :max_results

    attr_reader :skip_results

    def filter_equals(actual, expected)
      actual == expected
    end

    def indifferent_dig(hsh, keys)
      keys.reduce(hsh) do |obj, key|
        return UNDEFINED unless obj.respond_to?(:[])

        if key.is_a?(String)
          obj[key] || obj[key.intern]
        elsif key.is_a?(Symbol)
          obj[key] || obj[key.to_s]
        else
          obj[key]
        end
      end
    end

    def matches?(hsh)
      filters.all? do |(filter_name, keys, expected)|
        actual = indifferent_dig(hsh, keys)

        send("filter_#{filter_name}", actual, expected)
      end
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def matching_data
      skipped_count  = 0
      matching_count = 0
      items          = ordering? ? ordered_data : data

      items.each do |item|
        next unless matches?(item)

        next if skip_results && (skipped_count += 1) <= skip_results

        break if max_results && max_results < (matching_count += 1)

        yield transform ? transform.denormalize(item) : item
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    def parse_selector(hsh, keys)
      hsh.each do |key, value|
        nested = [*keys, key]

        next filters << [:equals, nested, value] unless value.is_a?(Hash)

        parse_selector(value, nested)
      end
    end
  end
end
