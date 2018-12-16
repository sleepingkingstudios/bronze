# frozen_string_literal: true

require 'bronze/entity'

module Spec
  class PlayingCard < Bronze::Entity
    attribute :suit,  String,  read_only: true
    attribute :value, Integer, read_only: true
  end
end
