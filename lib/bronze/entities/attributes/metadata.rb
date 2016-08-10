# lib/bronze/entities/attributes/metadata.rb

require 'bronze/entities/attributes'

module Bronze::Entities::Attributes
  # Data class that characterizes an entity attribute and allows for reflection
  # on its properties and options.
  class Metadata
    # @param attribute_name [String, Symbol] The name of the attribute.
    # @param attribute_type [Class] The type of the attribute.
    def initialize attribute_name, attribute_type
      @attribute_name = attribute_name.intern
      @reader_name    = attribute_name.intern
      @writer_name    = "#{attribute_name}=".intern

      @attribute_type = attribute_type
    end # method initialize

    # @return [String, Symbol] The name of the attribute.
    attr_reader :attribute_name

    # @return [Class] The type of the attribute.
    attr_reader :attribute_type

    # @return [String, Symbol] The name of the attribute's reader method.
    attr_reader :reader_name

    # @return [String, Symbol] The name of the attribute's writer method.
    attr_reader :writer_name

    # @return [Object] The default value for the attribute.
    def default_value
      nil
    end # method default_value
  end # class
end # module
