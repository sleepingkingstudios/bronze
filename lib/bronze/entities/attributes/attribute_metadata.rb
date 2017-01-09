# lib/bronze/entities/attributes/attribute_metadata.rb

require 'sleeping_king_studios/tools/toolbox/delegator'

require 'bronze/entities/attributes/attribute_type'

module Bronze::Entities::Attributes
  # Data class that characterizes an entity attribute and allows for reflection
  # on its properties and options.
  class AttributeMetadata
    extend SleepingKingStudios::Tools::Toolbox::Delegator

    # @param attribute_name [String, Symbol] The name of the attribute.
    # @param attribute_type [Class] The type of the attribute.
    # @param attribute_options [Hash] Additional options for the attribute.
    def initialize attribute_name, attribute_type, attribute_options
      @attribute_name = attribute_name.intern
      @reader_name    = attribute_name.intern
      @writer_name    = "#{attribute_name}=".intern

      @attribute_type    = AttributeType.new(attribute_type)
      @attribute_options = attribute_options
    end # method initialize

    # @return [String, Symbol] The name of the attribute.
    attr_reader :attribute_name

    # @return [Hash] Additional options for the attribute.
    attr_reader :attribute_options

    # @return [Bronze::Entities::Attributes::AttributeType] The type of the
    #   attribute.
    attr_reader :attribute_type

    # @return [String, Symbol] The name of the attribute's reader method.
    attr_reader :reader_name

    # @return [String, Symbol] The name of the attribute's writer method.
    attr_reader :writer_name

    delegate :collection?, :object_type, :to => :@attribute_type

    # @return [Boolean] True if the attribute allows nil values, otherwise
    #   false.
    def allow_nil?
      !!@attribute_options[:allow_nil]
    end # method allow_nil?

    # @return [Object] The default value for the attribute.
    def default
      val = @attribute_options[:default]

      val.is_a?(Proc) ? val.call : val
    end # method default
    alias_method :default_value, :default

    # @return [Boolean] True if the default value is set, otherwise false.
    def default?
      !@attribute_options[:default].nil?
    end # method default?

    # @return [Boolean] True if the attribute is a foreign key, otherwise false.
    def foreign_key?
      !!@attribute_options[:foreign_key]
    end # method foreign_key?

    # @return [Boolean] True if the attribute is read-only, otherwise false.
    def read_only?
      !!@attribute_options[:read_only]
    end # method read_only?
  end # class
end # module