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
    include Bronze::Entities::Attributes

    autoload :Builders, 'bronze/entities/associations/builders'
    autoload :Metadata, 'bronze/entities/associations/metadata'

    # Error class for handling invalid inverse associations.
    class InverseAssociationError < StandardError; end

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
        metadata = build_attribute(
          attribute_name,
          Bronze::Entities::PrimaryKey::KEY_TYPE,
          {
            :allow_nil => true,
            :read_only => true
          }, # end options
          :foreign_key => true
        ) # end build_attribute

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

      # Defines a has_many association with the specified entity.
      #
      # @example Defining an Association
      #   class Author < Bronze::Entities::Entity
      #     has_many :books
      #   end # class
      #
      #   author.id
      #   #=> 0
      #   author.books
      #   #=> []
      #
      #   book = Book.new(:name => 'Romance of the Three Kingdoms')
      #   book.author
      #   #=> nil
      #   book.author_id
      #   #=> nil
      #
      #   author.books << book
      #   #=> [#<Book>]
      #   book.author
      #   #=> #<Author>
      #   book.author_id
      #   #=> 0
      #
      # @param (see Associations::Builders::HasManyBuilder#build)
      #
      # @option (see Associations::Builders::HasManyBuilder#build)
      #
      # @return (see Associations::Builders::HasManyBuilder#build)
      #
      # @raise (see Associations::Builders::HasManyBuilder#build)
      def has_many association_name, association_options = {}
        builders = Bronze::Entities::Associations::Builders
        builder  = builders::HasManyBuilder.new(self)
        metadata = builder.build(association_name, association_options)

        (@associations ||= {})[metadata.association_name] = metadata
      end # class method has_many

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
      #   book.author = Author.new
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

      private

      attr_accessor :associations_module
    end # module

    # @param attributes [Hash] The default attributes with which to initialize
    #   the entity. Defaults to an empty hash.
    def initialize attributes = {}
      @associations = {}

      super

      attributes.each do |key, value|
        next unless association?(key)

        send("#{key}=", value)
      end # each
    end # constructor

    # Merges the values of the associations. Values that are not valid
    # associations are passed to the superclass.
    #
    # @param values [Hash{String, Symbol => Object}] The association values to
    #   set.
    #
    # @see Attributes#assign.
    def assign values
      super

      values.each do |key, value|
        next unless association?(key)

        send("#{key}=", value)
      end # each
    end # method assign

    # Checks if the entity defines the specified association.
    #
    # @param association_name [String, Symbol] The name of the association.
    #
    # @return [Boolean] True if the entity defines the association, otherwise
    #   false.
    def association? association_name
      self.class.associations.key?(association_name.intern)
    end # method association?

    private

    # rubocop:disable Metrics/MethodLength
    def write_has_many_association metadata, new_values
      validate_collection! metadata, new_values

      # 1. Locally cache prior values
      collection = get_association(metadata)

      unless collection
        collection ||=
          Bronze::Entities::Associations::Collection.new(self, metadata)

        set_association(metadata, collection)
      end # unless

      # 2. Break if old value == new value
      return collection if collection == new_values

      # 3. Clear local values
      collection.clear

      return collection if new_values.nil? || new_values.empty?

      # 5. Set local values
      new_values.each { |item| collection << item }

      collection
    end # method write_has_many_association
    # rubocop:enable Metrics/MethodLength

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
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
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
      if inverse_metadata && inverse_metadata.one?
        new_value.send(inverse_metadata.writer_name, self)
      elsif inverse_metadata
        new_value.send(inverse_metadata.reader_name) << self
      end # if

      new_value
    end # method write_references_one_association
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity
  end # module
end # module
