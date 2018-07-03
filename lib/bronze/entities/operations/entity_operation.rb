require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/entities/operations'

module Bronze::Entities::Operations
  # Abstract base class for operations that act on instances of an entity.
  module EntityOperation
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    # Class methods to define when including EntityOperation in a class.
    module ClassMethods
      # Defines a new subclass of the operation class and sets the entity class
      # of all subclass instances to the given entity class.
      #
      # @param entity_class [Class] The class of entity instances of the
      #   operation subclass will act upon.
      def subclass entity_class
        Class.new(self) do
          define_method :initialize do |*args, **kwargs, &block|
            kwargs = kwargs.merge(entity_class: entity_class)

            super(*args, **kwargs, &block)
          end
        end
      end
    end

    # @param entity_class [Class] The class of entity this operation acts upon.
    def initialize(*args, entity_class:, **kwargs)
      # RUBY_VERSION: Required below 2.5
      args << kwargs unless kwargs.empty?

      super(*args)

      @entity_class = entity_class
    end

    # @return [Class] The class of entity this operation acts upon.
    attr_reader :entity_class

    private

    def entity_name
      @entity_name ||=
        begin
          name = entity_class.name.split('::').last
          name = tools.string.underscore(name)

          tools.string.singularize(name)
        end
    end

    def plural_entity_name
      @plural_entity_name ||= tools.string.pluralize(entity_name)
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
