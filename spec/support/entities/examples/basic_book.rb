# frozen_string_literal: true

require 'bronze/entity'
require 'bronze/entities/primary_keys/uuid'

module Spec
  class BasicBook < Bronze::Entity
    include Bronze::Entities::PrimaryKeys::Uuid

    define_primary_key :uuid

    attribute :title,  String
    attribute :author, String
    attribute :genre,  String
  end
end
