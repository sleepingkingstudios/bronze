# lib/bronze/entities/associations/metadata.rb

require 'bronze/entities/associations'

module Bronze::Entities::Associations
  # Data classes that characterize entity associations and allow for
  # reflection on their properties and options.
  module Metadata
    autoload :AssociationMetadata,
      'bronze/entities/associations/metadata/association_metadata'
    autoload :HasOneMetadata,
      'bronze/entities/associations/metadata/has_one_metadata'
    autoload :ReferencesOneMetadata,
      'bronze/entities/associations/metadata/references_one_metadata'
  end # module
end # module
