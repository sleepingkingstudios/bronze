# frozen_string_literal: true

require 'bronze/transform'

module Spec
  class SymbolizeTransform < Bronze::Transform
    def denormalize(sym)
      sym.to_s
    end

    def normalize(str)
      str.intern
    end
  end
end
