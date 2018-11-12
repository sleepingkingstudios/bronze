require 'cuprum/operation'

require 'bronze/operations/entity_operation'
require 'bronze/operations/result'

module Bronze::Operations
  # Abstract base class for operations that act on instances of an entity.
  class BaseOperation < Cuprum::Operation
    prepend Bronze::Operations::EntityOperation

    def self.subclass(entity_class, **options)
      raise ArgumentError, 'must specify an entity class' unless entity_class

      options = options.merge(entity_class: entity_class)

      Class.new(self) do
        define_method :initialize do |*args, **kwargs, &block|
          kwargs = options.merge(kwargs)

          super(*args, **kwargs, &block)
        end
      end
    end

    def initialize(**_kwargs)
      # Ignore unrecognized keywords.
    end

    private

    def build_result(value = nil, **options)
      Bronze::Operations::Result.new(value, options)
    end
  end
end
