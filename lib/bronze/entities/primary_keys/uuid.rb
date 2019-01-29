# frozen_string_literal: true

require 'securerandom'

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/entities/primary_key'
require 'bronze/entities/primary_keys'

module Bronze::Entities::PrimaryKeys
  # Module for defining a UUID primary key attribute on an entity class.
  module Uuid
    extend SleepingKingStudios::Tools::Toolbox::Mixin
    include Bronze::Entities::PrimaryKey

    # Class methods to define when including PrimaryKeys::Uuid in a class.
    module ClassMethods
      # Defines a UUID primary key with the specified name.
      #
      # @example Defining a Primary Key
      #   class Book
      #     include Bronze::Entities::Attributes
      #     include Bronze::Entities::PrimaryKey::Uuid
      #
      #     define_primary_key :id
      #   end # class
      #
      #   book = Book.new
      #   book.id
      #   #=> '19eeac71-2b8b-439a-8f5d-cb63f26e4ddf'
      #
      #   Book.new.id
      #   #=> '4c08d721-8aa2-4ff9-942f-852b5c33bcc9'
      #
      # @param attribute_name [Symbol, String] The name of the primary key.
      #
      # @return [Attributes::Metadata] the metadata for the primary key
      #   attribute.
      def define_primary_key(attribute_name)
        super(attribute_name, String, default: -> { SecureRandom.uuid })
      end
    end
  end
end
