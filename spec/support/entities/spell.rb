# frozen_string_literal: true

require 'securerandom'

require 'bronze/entity'

module Spec
  class Spell < Bronze::Entity
    define_primary_key :hex, String, default: -> { SecureRandom.hex(8) }

    attribute :name,      String
    attribute :mana_cost, Integer
  end
end
