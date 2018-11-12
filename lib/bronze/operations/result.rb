require 'cuprum/result'

require 'bronze/errors'
require 'bronze/operations'

module Bronze::Operations
  # Custom result for Bronze operations. Uses Bronze::Errors to handle nested
  # error data.
  class Result < Cuprum::Result
    private

    def build_errors
      Bronze::Errors.new
    end
  end
end
