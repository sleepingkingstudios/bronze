# lib/bronze/entities/associations.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/entities/attributes'

module Bronze::Entities
  # Namespace for library classes and modules that build and characterize
  # entity associations.
  module Associations
    extend  SleepingKingStudios::Tools::Toolbox::Mixin
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
      #   #=> #<Author>
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

    protected

    def get_association association_name
      @associations[association_name]
    end # method set_association

    def set_association association_name, value
      @associations[association_name] = value
    end # method set_association
  end # module
end # module
