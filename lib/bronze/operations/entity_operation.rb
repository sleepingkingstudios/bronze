require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/operations'

module Bronze::Operations
  # Abstract operation mixin for operations that act on instances of an entity.
  module EntityOperation
    extend SleepingKingStudios::Tools::Toolbox::Mixin

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
