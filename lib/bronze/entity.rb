# frozen_string_literal: true

require 'bronze/entities/attributes'

module Bronze
  # Base class for implementing data entities.
  class Entity
    include Bronze::Entities::Attributes
  end
end
