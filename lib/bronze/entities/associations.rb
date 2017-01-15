# lib/bronze/entities/associations.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/entities/associations/helpers'
require 'bronze/entities/attributes'

module Bronze::Entities
  # Namespace for library classes and modules that build and characterize
  # entity associations.
  module Associations
    extend  SleepingKingStudios::Tools::Toolbox::Mixin
    include Bronze::Entities::Associations::Helpers
    prepend Bronze::Entities::Attributes

    autoload :Builders, 'bronze/entities/associations/builders'
    autoload :Metadata, 'bronze/entities/associations/metadata'

    # Class methods to define when including Associations in a class.
    module ClassMethods
      # Returns the metadata for the associations defined for the current class.
      #
      # @return [Hash{Symbol => Associations::Metadata::AssociationMetadata}]
      #   The metadata for the associations.
      def associations
        if superclass.respond_to?(:associations)
          superclass.associations.merge(@associations ||= {}).freeze
        else
          (@associations ||= {}).dup.freeze
        end # if-else
      end # class method associations

      # Defines a foreign key attribute.
      def foreign_key attribute_name
        builder  = Bronze::Entities::Attributes::AttributeBuilder.new(self)
        metadata = builder.build(
          attribute_name,
          Bronze::Entities::PrimaryKey::KEY_TYPE,
          {},
          :foreign_key => true
        ) # end build

        (@attributes ||= {})[metadata.attribute_name] = metadata
      end # class method foreign_key

      # rubocop:disable Style/PredicateName

      # Defines a has_one association with the specified entity.
      #
      # @example Defining an Association
      #   class Book < Bronze::Entities::Entity
      #     has_one :cover
      #   end # class
      #
      #   book.id
      #   #=> 0
      #   book.cover
      #   #=> nil
      #
      #   book.cover = Cover.new(:name => 'Luo Guanzhong')
      #   book.cover
      #   #=> #<Cover>
      #   cover.book_id
      #   #=> 0
      #
      # @param (see Associations::Builders::HasOneBuilder#build)
      #
      # @option (see Associations::Builders::HasOneBuilder#build)
      #
      # @return (see Associations::Builders::HasOneBuilder#build)
      #
      # @raise (see Associations::Builders::HasOneBuilder#build)
      def has_one association_name, association_options = {}
        builders = Bronze::Entities::Associations::Builders
        builder  = builders::HasOneBuilder.new(self)
        metadata = builder.build(association_name, association_options)

        (@associations ||= {})[metadata.association_name] = metadata
      end # class method has_one

      # rubocop:enable Style/PredicateName

      # Defines a references_one association with the specified entity.
      #
      # @example Defining an Association
      #   class Book < Bronze::Entities::Entity
      #     references_one :author
      #   end # class
      #
      #   book.author
      #   #=> nil
      #
      #   book.author = Author.new(:name => 'Luo Guanzhong')
      #   book.author
      #   #=> #<Author id=0>
      #   book.author_id
      #   #=> 0
      #
      # @param (see Associations::Builders::ReferencesOneBuilder#build)
      #
      # @option (see Associations::Builders::ReferencesOneBuilder#build)
      #
      # @return (see Associations::Builders::ReferencesOneBuilder#build)
      #
      # @raise (see Associations::Builders::ReferencesOneBuilder#build)
      def references_one association_name, association_options = {}
        builders = Bronze::Entities::Associations::Builders
        builder  = builders::ReferencesOneBuilder.new(self)
        metadata = builder.build(association_name, association_options)

        (@associations ||= {})[metadata.association_name] = metadata
      end # class method references_one
      alias_method :belongs_to, :references_one
    end # module

    # @param attributes [Hash] The default attributes with which to initialize
    #   the entity. Defaults to an empty hash.
    def initialize attributes = {}
      @associations = {}

      attributes.each do |key, value|
        next unless self.class.associations.key?(key)

        send("#{key}=", value)
      end # each

      super
    end # constructor

    private

    # rubocop:disable Metrics/MethodLength
    def write_has_one_association metadata, new_value
      validate_association! metadata, new_value

      # 1. Locally cache prior values
      inverse_metadata = metadata.inverse_metadata
      prior_value      = get_association(metadata)

      # 2. Break if old value == new value
      return if prior_value == new_value

      # 3. Clear local values
      set_association(metadata, nil)

      # 4. Clear prior inverse
      if prior_value && inverse_metadata
        prior_value.send(inverse_metadata.writer_name, nil)
      end # if

      return if new_value.nil?

      # 5. Set local values
      set_association(metadata, new_value)

      # 6. Set new inverse
      if inverse_metadata
        new_value.send(inverse_metadata.writer_name, self)
      end # if

      new_value
    end # method write_has_one_association

    def write_references_one_association metadata, new_value
      validate_association! metadata, new_value

      # 1. Locally cache prior values
      inverse_metadata = metadata.inverse_metadata
      prior_value      = get_association(metadata)

      # 2. Break if old value == new value
      return if prior_value == new_value

      # 3. Clear local values
      set_association(metadata, nil)
      set_foreign_key(metadata, nil)

      # 4. Clear prior inverse
      if inverse_metadata && prior_value
        prior_value.send(inverse_metadata.writer_name, nil)
      end # if

      return if new_value.nil?

      # 5. Set local values
      set_association(metadata, new_value)
      set_foreign_key(metadata, new_value.id)

      # 6. Set new inverse
      if inverse_metadata
        new_value.send(inverse_metadata.writer_name, self)
      end # if

      new_value
    end # method write_references_one_association
    # rubocop:enable Metrics/MethodLength
  end # module
end # module
