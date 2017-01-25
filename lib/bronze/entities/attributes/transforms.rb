# lib/bronze/entities/attributes/transforms.rb

require 'bronze/entities/attributes'

module Bronze::Entities::Attributes
  # @api private
  module Transforms
    autoload :BigDecimalTransform,
      'bronze/entities/attributes/transforms/big_decimal_transform'
    autoload :DateTimeTransform,
      'bronze/entities/attributes/transforms/date_time_transform'
    autoload :DateTransform,
      'bronze/entities/attributes/transforms/date_transform'
    autoload :SymbolTransform,
      'bronze/entities/attributes/transforms/symbol_transform'
    autoload :TimeTransform,
      'bronze/entities/attributes/transforms/time_transform'

    class << self
      def transform_for object_type
        builtin_transform_for object_type
      end # class method transform_for

      private

      def builtin_transform_for object_type
        const_get("#{object_type.name}Transform").instance
      rescue NameError => _exception
        nil
      end # class method builtin_transform_for
    end # class
  end # module
end # module
