# frozen_string_literal: true

require 'bronze/transform'

module Spec
  class UpcaseTransform < Bronze::Transform
    def denormalize(str)
      str.downcase
    end

    def normalize(str)
      str.upcase
    end
  end
end
