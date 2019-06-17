# frozen_string_literal: true

require 'bronze/transform'

module Spec
  class CapitalizeKeysTransform < Bronze::Transform
    def denormalize(hsh)
      map_keys(hsh, &:capitalize)
    end

    def normalize(hsh)
      map_keys(hsh) { |str| str[0].downcase + str[1..-1] }
    end

    private

    def map_keys(hsh)
      return hsh unless hsh.is_a?(Hash)

      Hash[hsh.map { |key, value| [yield(key), value] }]
    end
  end
end
