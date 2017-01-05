# lib/bronze/entities/associations/metadata/association_metadata.rb

require 'bronze/entities/associations/metadata'

module Bronze::Entities::Associations::Metadata
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

    # @param association_type [Symbol] The type of the association.
    # @param association_name [String, Symbol] The name of the association.
    # @param association_options [Hash] Additional options for the association.
    def initialize association_type, association_name, association_options
      @association_name = association_name.intern
      @association_type = association_type

      hash_tools = SleepingKingStudios::Tools::HashTools
      options    = hash_tools.convert_keys_to_symbols(association_options)
      validate_options(options)
      @association_options = options
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

    # @return [Symbol] The name of the foreign key reader method, if any.
    def foreign_key_reader_name
      foreign_key
    end # method foreign_key_reader_name

    # @return [Symbol] The name of the foreign key writer method, if any.
    def foreign_key_writer_name
      return nil unless foreign_key?

      @foreign_key_writer_name ||= :"#{foreign_key}="
    end # method foreign_key_writer_name

    # @return [Boolean] True if an inverse association is defined, otherwise
    #   false.
    def inverse?
      !!inverse_name
    end # method inverse?

    # @return [AssociationMetadata] The metadata for the inverse association,
    #   if any.
    def inverse_metadata
      association_class.associations[inverse_name]
    end # method inverse_metadata

    # @return [Symbol] The name of the inverse association, if any.
    def inverse_name
      @inverse_name ||= options[:inverse]
    end # method inverse_name

    # @return [Symbol] The name of tbe association reader method.
    def reader_name
      @reader_name ||= association_name
    end # method reader_name

    # @return [Symbol] The name of tbe association writer method.
    def writer_name
      @writer_name ||= :"#{association_name}="
    end # method writer_name

    private

    def validate_allowed_options keys
      invalid_options = keys - self.class.valid_keys

      return if invalid_options.empty?

      tools   = SleepingKingStudios::Tools::ArrayTools
      message = 'invalid option'
      message << 's' if invalid_options.count > 1
      message << ' ' << tools.humanize_list(invalid_options, &:inspect)

      raise ArgumentError, message
    end # method validate_allowed_options

    def validate_required_options keys
      missing_options = self.class.required_keys - keys

      return if missing_options.empty?

      tools   = SleepingKingStudios::Tools::ArrayTools
      message = 'missing option'
      message << 's' if missing_options.count > 1
      message << ' ' << tools.humanize_list(missing_options, &:inspect)

      raise ArgumentError, message
    end # method validate_required_options

    def validate_options opts
      keys = opts.keys

      validate_allowed_options(keys)

      validate_required_options(keys)
    end # method validate_options
  end # class
end # module
