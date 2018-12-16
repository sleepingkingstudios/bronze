# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/entities'

module Bronze::Entities
  # Module for defining a primary key attribute on an entity class.
  module PrimaryKey
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    # Class methods to define when including Attributes in a class.
    module ClassMethods
      # Defines the primary key with the specified name and type.
      #
      # @example Defining a Primary Key
      #   class Book
      #     include Bronze::Entities::Attributes
      #     include Bronze::Entities::PrimaryKey
      #
      #     next_id = -1
      #     define_primary_key :id, Integer, default: -> { next_id += 1 }
      #   end # class
      #
      #   book = Book.new
      #   book.id
      #   #=> 0
      #
      #   Book.new.id
      #   #=> 1
      #
      # @param attribute_name [Symbol, String] The name of the primary key.
      # @param attribute_type [Class] The type of the primary key.
      # @param default [Proc] The proc to call when generating a new primary
      #   key.
      #
      # @return [Attributes::Metadata] the metadata for the primary key
      #   attribute.
      def define_primary_key(attribute_name, attribute_type, default:)
        @primary_key =
          attribute(
            attribute_name,
            attribute_type,
            default:     default,
            primary_key: true,
            read_only:   true
          )
      end

      # @return [Attributes::Metadata] the metadata for the primary key
      #   attribute, or nil if the primary key is not defined.
      def primary_key
        return @primary_key if @primary_key

        return superclass.primary_key if superclass.respond_to?(:primary_key)

        nil
      end
    end

    # @return [Object] the primary key for the current entity.
    def primary_key
      attribute_name = self.class.primary_key&.name

      return nil unless attribute_name

      get_attribute(attribute_name)
    end
  end
end
