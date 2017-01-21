# lib/bronze/entities/associations/builders/association_builder.rb

require 'sleeping_king_studios/tools/toolbelt'

require 'bronze/entities/associations'

module Bronze::Entities::Associations::Builders
  # Service class to define associations on an entity.
  class AssociationBuilder
    # @param entity_class [Class] The entity class on which associations will be
    #   defined.
    def initialize entity_class
      @entity_class = entity_class
    end # constructor

    # @return [Class] The entity class on which associations will be defined.
    attr_reader :entity_class

    private

    def entity_class_associations
      @entity_class_associations ||=
        begin
          unless entity_class.const_defined?(:Associations)
            entity_class.const_set(:Associations, Module.new)

            entity_class.include entity_class::Associations
          end # unless

          entity_class::Associations
        end # begin
    end # method entity_class_associations

    def options_with_class_name options, name
      return options if options.key?(:class_name)

      name = tools.string.camelize(name)
      name = tools.string.singularize(name)

      options.update(:class_name => name)
    end # method options_with_class_name

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end # method tools
  end # class
end # module
