# frozen_string_literal: true

require 'bronze/entities/attributes'

require 'support/entities/book'

module Spec
  class RareBook < Book
    attribute :rarity, String
  end
end
