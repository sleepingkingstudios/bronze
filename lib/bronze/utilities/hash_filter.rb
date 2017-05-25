# lib/bronze/utilities/hash_filter.rb

require 'bronze/utilities'

module Bronze::Utilities
  # Performs advanced matching on Hash data objects using the Query syntax.
  class HashFilter
    # @param selector [Hash] The criteria by which to match the data.
    def initialize selector
      @selector = selector

      partition_selector
    end # method initialize

    # @return [Hash] A hash of attribute filters, which individual attribute
    #   values must satisfy for the data to match.
    attr_reader :filters

    # @return [Hash] The criteria by which to match the data.
    attr_reader :selector

    # @return [Hash] A generated hash such that all data matching the filter
    #   must be a proper superset of the hash.
    attr_reader :subhash

    # @param data [Hash] The data to match.
    #
    # @return [Boolean] True if the data matches the selector, otherwise false.
    def matches? data
      return false unless data >= @subhash

      @filters.all? do |attributes, attribute_filters|
        attribute_filters.all? do |filter, params|
          attribute_value = indifferent_dig(data, attributes)
          filter_method   = "filter_#{filter.to_s[2..-1]}"

          send(filter_method, attribute_value, params)
        end # all?
      end # all?
    end # method matches?

    private

    def eager_dig hsh, keys
      keys.reduce(hsh) do |nested, key|
        nested[key] ||= {}
      end # method reduce
    end # method eager_dig

    def filter_eq value, expected
      value == expected
    end # method filter_eq

    def filter_in value, expected
      expected.include?(value)
    end # method filter_in

    def filter_ne value, expected
      value != expected
    end # method filter_ne

    # rubocop:disable Metrics/MethodLength
    def indifferent_dig hsh, keys
      keys.reduce(hsh) do |nested, key|
        next nil unless nested

        case key
        when String
          nested.key?(key) ? nested[key] : nested[key.intern]
        when Symbol
          nested.key?(key) ? nested[key] : nested[key.to_s]
        else
          nested[key]
        end # case
      end # method reduce
    end # method indifferent_dig
    # rubocop:enable Metrics/MethodLength

    def partition_selector
      @subhash = {}
      @filters = {}

      partition_selector_hash @selector, []
    end # method partition_selector

    def partition_selector_hash hsh, attributes
      hsh.each do |key, value|
        if key.to_s.start_with?('__')
          (@filters[attributes] ||= []) << [key, value]
        else
          unless value.is_a?(Hash)
            next eager_dig(@subhash, attributes)[key] = value
          end # unless

          partition_selector_hash value, attributes + [key]
        end # if
      end # each
    end # method partition_selector_hash
  end # class
end # module
