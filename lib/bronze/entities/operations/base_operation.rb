require 'cuprum/operation'

require 'bronze/entities/operations/entity_operation'

module Bronze::Entities::Operations
  # Abstract base class for operations that act on instances of an entity.
  class BaseOperation < Cuprum::Operation
    prepend Bronze::Entities::Operations::EntityOperation

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

    def build_errors
      Bronze::Errors.new
    end
  end
end
