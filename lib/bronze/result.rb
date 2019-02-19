# frozen_string_literal: true

require 'cuprum/result'

require 'bronze'
require 'bronze/errors'

module Bronze
  # Custom result object that stores errors in a nested errors object.
  class Result < Cuprum::Result
    private

    def build_errors
      Bronze::Errors.new
    end
  end
end
