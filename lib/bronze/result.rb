# frozen_string_literal: true

require 'cuprum/result'

require 'bronze'
require 'bronze/errors'

module Bronze
  # Custom result object that stores errors in a nested errors object.
  class Result < Cuprum::Result
    def initialize(value = nil, errors: nil)
      super(value: value, error: errors || build_errors)
    end

    alias_method :errors, :error

    private

    def build_errors
      Bronze::Errors.new
    end

    def resolve_status(status)
      return error.nil? || error.empty? ? :success : :failure if status.nil?

      # :nocov:
      super
      # :nocov:
    end
  end
end
