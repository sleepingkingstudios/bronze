# lib/bronze/entities/entity.rb

require 'bronze/entities/associations'
require 'bronze/entities/attributes'
require 'bronze/entities/base_entity'
require 'bronze/entities/normalization'
require 'bronze/entities/primary_key'

require 'bronze/entities/ulid'

module Bronze::Entities
  # Base class for implementing data entities, which store information about
  # business objects without making assumptions about or tying the
  # implementation to any specific framework or data repository.
  class Entity < BaseEntity
    include Bronze::Entities::Attributes
    include Bronze::Entities::Associations
    include Bronze::Entities::PrimaryKey
    include Bronze::Entities::Normalization
  end # class
end # module
