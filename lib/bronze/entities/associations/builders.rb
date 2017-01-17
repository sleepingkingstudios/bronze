# lib/bronze/entities/associations/builders.rb

require 'bronze/entities/associations'

module Bronze::Entities::Associations
  # Builder classes that set up associations between entities.
  module Builders
    autoload :AssociationBuilder,
      'bronze/entities/associations/builders/association_builder'
    autoload :HasManyBuilder,
      'bronze/entities/associations/builders/has_many_builder'
    autoload :HasOneBuilder,
      'bronze/entities/associations/builders/has_one_builder'
    autoload :ReferencesOneBuilder,
      'bronze/entities/associations/builders/references_one_builder'
  end # module
end # module
