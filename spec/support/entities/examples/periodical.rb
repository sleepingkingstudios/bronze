# frozen_string_literal: true

require 'date'

require 'bronze/entity'
require 'bronze/entities/primary_key'

module Spec
  class Periodical < Bronze::Entity
    include Bronze::Entities::PrimaryKey

    def self.collection_name
      'periodicals'
    end

    define_primary_key :id, Integer, default: -1

    attribute :title,     String
    attribute :issue,     Integer
    attribute :headline,  String
    attribute :date,      Date
    attribute :publisher, String
  end
end
