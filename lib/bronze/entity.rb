# frozen_string_literal: true

require 'bronze/entities/attributes'
require 'bronze/entities/normalization'
require 'bronze/entities/primary_key'

module Bronze
  # Base class for implementing data entities.
  class Entity
    include Bronze::Entities::Attributes
    include Bronze::Entities::Normalization
    include Bronze::Entities::PrimaryKey
  end
end
