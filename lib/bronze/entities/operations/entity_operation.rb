# lib/bronze/entities/operations/entity_operation.rb

require 'bronze/entities/operations'
require 'bronze/operations/operation'

module Bronze::Entities::Operations
  # Abstract base class for operations that act on instances of an entity.
  class EntityOperation < Bronze::Operations::Operation
    # Defines a new subclass of the operation class and sets the entity class of
    # all subclass instances to the given entity class.
    #
    # @param entity_class [Class] The class of entity instances of the operation
    #   subclass wil act upon.
    def self.subclass entity_class
      Class.new(self) do
        define_method :initialize do |*args, &block|
          super(entity_class, *args, &block)
        end # constructor
      end # class
    end # class method subclass

    # @param entity_class [Class] The class of entity this operation acts upon.
    def initialize entity_class
      @entity_class = entity_class
    end # constructor

    # @return [Class] The class of entity this operation acts upon.
    attr_reader :entity_class

    private

    def entity_name
      @entity_name ||=
        begin
          name = entity_class.name.split('::').last
          name = tools.string.underscore(name)

          tools.string.singularize(name)
        end # entity_name
    end # method entity_name

    def plural_entity_name
      @plural_entity_name ||= tools.string.pluralize(entity_name)
    end # method entity_name

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end # method tools
  end # class
end # module
