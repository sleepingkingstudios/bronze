# lib/bronze/entities/entity.rb

require 'bronze/entities/attributes/builder'

module Bronze::Entities
  # Base class for implementing data entities, which store information about
  # business objects without making assumptions about or tying the
  # implementation to any specific framework or data repository.
  class Entity
    # @param attributes [Hash] The default attributes with which to initialize
    #   the entity. Defaults to an empty hash.
    def initialize attributes = {}
      @attributes = attributes
    end # constructor

    # Defines an attribute with the specified name and type.
    #
    # @example Defining an Attribute
    #   class Book < Bronze::Entities::Entity
    #     attribute :title, String
    #   end # class
    #
    #   book.title
    #   #=> nil
    #
    #   book.title = 'Romance of the Three Kingdoms'
    #   book.title
    #   #=> 'Romance of the Three Kingdoms'
    #
    # @param (see Attributes::Builder#build)
    #
    # @raise (see Attributes::Builder#build)
    def self.attribute attribute_name, attribute_type, _attribute_options = {}
      builder = Bronze::Entities::Attributes::Builder.new(self)

      builder.build(attribute_name, attribute_type)
    end # class method attribute
  end # class
end # module
