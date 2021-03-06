# lib/bronze/entities/entity.rb

require 'bronze/entities/associations'
require 'bronze/entities/attributes'
require 'bronze/entities/attributes/dirty_tracking'
require 'bronze/entities/base_entity'
require 'bronze/entities/normalization'
require 'bronze/entities/normalization/associations'
require 'bronze/entities/persistence'
require 'bronze/entities/primary_key'
require 'bronze/entities/uniqueness'

require 'bronze/entities/ulid'

module Bronze::Entities
  # Base class for implementing data entities, which store information about
  # business objects without making assumptions about or tying the
  # implementation to any specific framework or data repository.
  class Entity < BaseEntity
    include Bronze::Entities::Attributes
    include Bronze::Entities::Attributes::DirtyTracking
    include Bronze::Entities::Associations
    include Bronze::Entities::PrimaryKey
    include Bronze::Entities::Normalization
    include Bronze::Entities::Normalization::Associations
    include Bronze::Entities::Persistence
    include Bronze::Entities::Uniqueness
  end # class
end # module
