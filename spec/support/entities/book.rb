# frozen_string_literal: true

require 'date'

require 'bronze/entities/attributes'

module Spec
  class Book
    include Bronze::Entities::Attributes

    attribute :title,            String
    attribute :subtitle,         String, allow_nil: true
    attribute :isbn,             String, read_only: true
    attribute :page_count,       Integer
    attribute :publication_date, Date
    attribute :introduction,
      String,
      default: <<~DEFAULT.gsub(/\s+/, ' ').strip
        In a hole in the ground there lived a hobbit. Not a nasty, dirty, wet
        hole, filled with the ends of worms and an oozy smell, nor yet a dry,
        bare, sandy hole with nothing in it to sit down on or to eat: it was a
        hobbit-hole, and that means comfort.
      DEFAULT

=begin # rubocop:disable Style/BlockComments
    references_one :author
    has_one :cover
    has_many :endorsements
    has_many :endorsed_authors, through: :endorsements
    has_and_belongs_to_many :publishers
    embeds_one :preface
    embeds_many :chapters
=end
    # rubocop:enable Style/BlockComments
  end
end
