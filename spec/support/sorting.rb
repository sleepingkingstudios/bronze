# frozen_string_literal: true

module Spec::Support
  class Sorting
    DESCENDING = [:desc, 'desc'].freeze

    def self.sort_hashes(items, ordering)
      new.sort_hashes(items, ordering)
    end

    def initialize(options = {})
      @options = default_options.merge(options)
    end

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

    attr_reader :options

    def compare_attributes(attribute, first, second, reversed:)
      first_value  = get_attribute(first,  attribute)
      second_value = get_attribute(second, attribute)

      return nil if first_value.nil? && second_value.nil?

      comparison = compare_values(first_value, second_value)

      return nil if comparison.zero?

      reversed ? -comparison : comparison
    end

    def compare_values(first, second)
      if sort_nils_before_values
        # :nocov:
        return -1 if first.nil?
        return 1  if second.nil?
        # :nocov:
      else
        return 1  if first.nil?
        return -1 if second.nil?
      end

      first <=> second
    end

    def default_options
      {
        sort_nils_before_values: false
      }
    end

    def get_attribute(object, attribute)
      return object[attribute] if object.respond_to?(:[])

      object.send(attribute)
    end

    def sort_nils_before_values
      options.fetch(:sort_nils_before_values, false)
    end
  end
end
