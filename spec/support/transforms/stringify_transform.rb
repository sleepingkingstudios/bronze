# frozen_string_literal: true

require 'bronze/transform'

module Spec
  class StringifyTransform < Bronze::Transform
    def denormalize(sym)
      sym.intern
    end

    def normalize(str)
      str.to_s
    end
  end
end
