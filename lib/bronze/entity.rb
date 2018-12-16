# frozen_string_literal: true

require 'bronze/entities/attributes'
require 'bronze/entities/primary_key'

module Bronze
  # Base class for implementing data entities.
  class Entity
    include Bronze::Entities::Attributes
    include Bronze::Entities::PrimaryKey
  end
end
