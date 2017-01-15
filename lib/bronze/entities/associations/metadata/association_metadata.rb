# lib/bronze/entities/associations/metadata/association_metadata.rb

require 'sleeping_king_studios/tools/toolbelt'

require 'bronze/entities/associations/metadata'

module Bronze::Entities::Associations::Metadata
  # rubocop:disable Metrics/ClassLength

  # Base class that characterizes an entity association and allows for
  # reflection on its properties and options.
  class AssociationMetadata
    # Optional configuration keys for an association.
    OPTIONAL_KEYS = %i(inverse).freeze

    # Required configuration keys for an association.
    REQUIRED_KEYS = %i(class_name).freeze

    class << self
      def optional_keys
        @optional_keys ||=
          ancestors.reduce([]) do |opts, klass|
            break opts unless klass <= AssociationMetadata

            (opts + klass::OPTIONAL_KEYS).uniq
          end # reduce
      end # method valid_options

      def required_keys
        @required_keys ||=
          ancestors.reduce([]) do |opts, klass|
            break opts unless klass <= AssociationMetadata

            (opts + klass::REQUIRED_KEYS).uniq
          end # map
      end # method required_keys

      def valid_keys
        optional_keys + required_keys
      end # method valid_keys
    end # class << self

    # @param entity_class [Class] The class of entity whose association is
    #   characterized by the metadata.
    # @param association_type [Symbol] The type of the association.
    # @param association_name [String, Symbol] The name of the association.
    # @param association_options [Hash] Additional options for the association.
    def initialize(
      entity_class,
      association_type,
      association_name,
      association_options
    ) # end params
      @entity_class     = entity_class
      @association_name = association_name.intern
      @association_type = association_type

      options = tools.hash.convert_keys_to_symbols(association_options)
      @association_options = validate_options(options)
    end # method initialize

    # @return [Symbol] The name of the association.
    attr_reader :association_name
    alias_method :name, :association_name

    # @return [Symbol] The type of the association.
    attr_reader :association_type
    alias_method :type, :association_type

    # @return [Hash] Additional options for the association.
    attr_reader :association_options
    alias_method :options, :association_options

    # @return [Class] The class of entity whose association is characterized by
    #   the metadata.
    attr_reader :entity_class

    # @return [Class] The associated class.
    def association_class
      self.class.const_get(class_name)
    end # method association_class
    alias_method :klass, :association_class

    # @return [String] The name of the associated class.
    def class_name
      @association_options[:class_name]
    end # method class_name

    # @return [Symbol] The foreign key for the association, if any.
    def foreign_key
      @association_options[:foreign_key]
    end # method foreign_key

    # @return [Boolean] True if the association defines a foreign key, otherwise
    #   false.
    def foreign_key?
      @foreign_key_defined ||= !!foreign_key
    end # method foreign_key?

    # @return [AttributeMetadata] The metadata for the foreign key attribute.
    def foreign_key_metadata
      return nil unless foreign_key?

      @foreign_key_metadata = entity_class.attributes[foreign_key]
    end # method foreign_key_metadata

    # @return [Symbol] The name of the foreign key reader method, if any.
    def foreign_key_reader_name
      return nil unless foreign_key_metadata

      foreign_key_metadata.reader_name
    end # method foreign_key_reader_name

    # @return [Class] The type of the foreign key, if any.
    def foreign_key_type
      return nil unless foreign_key_metadata

      foreign_key_metadata.object_type
    end # method foreign_key_type

    # @return [Symbol] The name of the foreign key writer method, if any.
    def foreign_key_writer_name
      return nil unless foreign_key_metadata

      foreign_key_metadata.writer_name
    end # method foreign_key_writer_name

    # @return [Boolean] True if an inverse association is defined, otherwise
    #   false.
    def inverse?
      options.key?(:inverse)
    end # method inverse?

    # @return [AssociationMetadata] The metadata for the inverse association,
    #   if any.
    def inverse_metadata
      association_class.associations[inverse_name]
    end # method inverse_metadata

    # @return [Symbol] The name of the inverse association, if any.
    def inverse_name
      return nil unless inverse?

      @inverse_name ||= normalize_inverse_name
    end # method inverse_name

    # @return [Boolean] True if the association relates many objects, such as a
    #   :has_many association; otherwise false.
    def many?
      false
    end # method many?

    # @return [Boolean] True if the association relates one object, such as a
    #   :has_one or :references_one association; otherwise false.
    def one?
      false
    end # method one?

    # @return [Symbol] The name of tbe association reader method.
    def reader_name
      @reader_name ||= association_name
    end # method reader_name

    # @return [Symbol] The name of tbe association writer method.
    def writer_name
      @writer_name ||= :"#{association_name}="
    end # method writer_name

    private

    def normalize_inverse_name
      name = options[:inverse].to_s
      name = tools.string.underscore(name)

      name.intern
    end # method normalize_inverse_name

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end # method tools

    def validate_allowed_options keys
      invalid_options = keys - self.class.valid_keys

      return if invalid_options.empty?

      message = 'invalid option'
      message << 's' if invalid_options.count > 1
      message << ' ' << tools.array.humanize_list(invalid_options, &:inspect)

      raise ArgumentError, message
    end # method validate_allowed_options

    def validate_required_options keys
      missing_options = self.class.required_keys - keys

      return if missing_options.empty?

      message = 'missing option'
      message << 's' if missing_options.count > 1
      message << ' ' << tools.array.humanize_list(missing_options, &:inspect)

      raise ArgumentError, message
    end # method validate_required_options

    def validate_options opts
      keys = opts.keys

      validate_allowed_options(keys)

      validate_required_options(keys)

      opts
    end # method validate_options
  end # class

  # rubocop:enable Metrics/ClassLength
end # module
