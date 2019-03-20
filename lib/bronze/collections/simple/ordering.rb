# frozen_string_literal: true

require 'bronze/collections/simple'

module Bronze::Collections::Simple
  # Helpers for generating and using ordering criteria in queries on a Array of
  # Hashes data structure.
  module Ordering
    private

    def compare(first_item, second_item, attribute)
      first_value  = first_item[attribute]
      second_value = second_item[attribute]

      if first_value.nil?
        return second_value.nil? ? 0 : 1
      end

      return -1 if second_value.nil?

      first_value <=> second_value
    end

    def generate_ordering(attributes)
      raise ArgumentError, "ordering can't be empty" if attributes.empty?

      attributes.reduce({}) do |ordering, value|
        if value.is_a?(String) || value.is_a?(Symbol)
          next ordering.merge(value.intern => :asc)
        end

        next ordering.merge(generate_ordering_hash(value)) if value.is_a?(Hash)

        raise ArgumentError, "invalid ordering - #{value.inspect}"
      end
    end

    def generate_ordering_hash(value)
      hsh = {}

      value.each do |attribute, direction|
        unless attribute.is_a?(String) || attribute.is_a?(Symbol)
          raise ArgumentError,
            "invalid ordering - #{attribute.inspect}: #{direction.inspect}"
        end

        hsh[attribute.intern] = normalize_sort_direction(attribute, direction)
      end

      hsh
    end

    def ordering?
      @ordering.is_a?(Hash)
    end

    def ordered_data
      # The index (ui, vi) is used to ensure the sort result is stable.
      data.each.with_index.sort do |(u, ui), (v, vi)|
        cmp = nil

        @ordering.each do |attribute, direction|
          val = compare(u, v, attribute.to_s)

          next if val.zero?

          break cmp = direction == :asc ? val : -val
        end

        cmp || (ui <=> vi)
      end.map(&:first)
    end

    def normalize_sort_direction(attribute, value)
      value = value.intern if value.is_a?(String)
      value = :asc  if value == :ascending
      value = :desc if value == :descending

      # rubocop:disable Style/MultipleComparison
      return value if value == :asc || value == :desc

      # rubocop:enable Style/MultipleComparison

      raise ArgumentError,
        "invalid ordering (#{attribute.inspect} => #{value.inspect})" \
        ' - sort direction must be "ascending" (or :asc) or "descending"' \
        ' (or :desc)'
    end
  end
end
