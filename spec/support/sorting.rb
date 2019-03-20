# frozen_string_literal: true

module Spec::Support
  module Sorting
    class << self
      DESCENDING = [:desc, 'desc'].freeze

      def sort_hashes(items, ordering)
        items
          .each.with_index.sort do |(u, ui), (v, vi)|
            ordering.reduce(nil) do |memo, (attribute, direction)|
              reversed = DESCENDING.include?(direction)

              memo || compare_attributes(attribute, u, v, reversed: reversed)
            end || (ui <=> vi)
          end
          .map(&:first)
      end

      private

      def compare_attributes(attribute, first, second, reversed:)
        first_value  = first[attribute]
        second_value = second[attribute]

        return nil if first_value.nil? && second_value.nil?

        comparison = compare_values(first_value, second_value)

        return nil if comparison.zero?

        reversed ? -comparison : comparison
      end

      def compare_values(first, second)
        return 1  if first.nil?
        return -1 if second.nil?

        first <=> second
      end
    end
  end
end
