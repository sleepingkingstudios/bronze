# frozen_string_literal: true

require 'bronze/entity'
require 'bronze/entities/primary_keys/uuid'

module Spec
  class Monster < Bronze::Entity
    include Bronze::Entities::PrimaryKeys::Uuid

    define_primary_key :uuid

    attribute :name,  String
    attribute :level, Integer
  end
end
