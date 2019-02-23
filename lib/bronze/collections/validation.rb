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

    def data_not_nil_error(data)
      return unless data.nil?

      build_errors.add(Bronze::Collections::Errors.data_missing)
    end

    def errors_for_data(data)
      data_not_nil_error(data) ||
        data_invalid_error(data) ||
        data_empty_error(data)
    end

    def errors_for_selector(selector)
      selector_not_nil_error(selector) || selector_invalid_error(selector)
    end

    def selector_invalid_error(selector)
      return if selector.is_a?(Hash)

      build_errors
        .add(Bronze::Collections::Errors.selector_invalid, selector: selector)
    end

    def selector_not_nil_error(selector)
      return unless selector.nil?

      build_errors.add(Bronze::Collections::Errors.selector_missing)
    end
  end
end
