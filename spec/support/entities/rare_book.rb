# frozen_string_literal: true

require 'bronze/entities/attributes'

require 'support/entities/book'

module Spec
  class RareBook < Book
    # Enumerable attribute - rare, medium-rare, medium, medium-well, well-done.
    attribute :rarity, String
  end
end
