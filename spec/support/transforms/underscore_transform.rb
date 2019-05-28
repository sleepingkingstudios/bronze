# frozen_string_literal: true

require 'bronze/transform'

module Spec
  class UnderscoreTransform < Bronze::Transform
    def denormalize(str)
      tools.string.camelize(str)
    end

    def normalize(str)
      tools.string.underscore(str)
    end

    private

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
