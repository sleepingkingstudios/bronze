# frozen_string_literal: true

require 'bronze/collections'
require 'bronze/collections/errors'
require 'bronze/errors'

module Bronze::Collections
  # Methods for validating data and selectors in collection methods.
  module Validation
    private

    def build_errors
      Bronze::Errors.new
    end

    def data_empty_error(data)
      return unless data.empty?

      build_errors.add(Bronze::Collections::Errors.data_empty, data: data)
    end

    def data_invalid_error(data)
      return if data.is_a?(Hash)

      build_errors.add(Bronze::Collections::Errors.data_invalid, data: data)
    end

    def data_missing_error(data)
      return unless data.nil?

      build_errors.add(Bronze::Collections::Errors.data_missing)
    end

    def errors_for_data(data)
      data_missing_error(data) ||
        data_invalid_error(data) ||
        data_empty_error(data)
    end

    def errors_for_primary_key_insert(data)
      return unless primary_key?

      value = data[primary_key] || data[primary_key.to_s]

      primary_key_missing_error(value) ||
        primary_key_invalid_error(value) ||
        primary_key_empty_error(value)
    end

    def errors_for_selector(selector)
      selector_missing_error(selector) || selector_invalid_error(selector)
    end

    def primary_key_empty_error(value)
      return unless value.respond_to?(:empty?) && value.empty?

      build_errors[primary_key].add(
        Bronze::Collections::Errors.primary_key_empty,
        value: value.to_s
      )
    end

    def primary_key_invalid_error(value)
      return if value.is_a?(primary_key_type)

      build_errors[primary_key].add(
        Bronze::Collections::Errors.primary_key_invalid,
        type:  primary_key_type.to_s,
        value: value.to_s
      )
    end

    def primary_key_missing_error(value)
      return unless value.nil?

      build_errors[primary_key].add(
        Bronze::Collections::Errors.primary_key_missing
      )
    end

    def selector_invalid_error(selector)
      return if selector.is_a?(Hash)

      build_errors
        .add(Bronze::Collections::Errors.selector_invalid, selector: selector)
    end

    def selector_missing_error(selector)
      return unless selector.nil?

      build_errors.add(Bronze::Collections::Errors.selector_missing)
    end
  end
end
