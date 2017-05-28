# lib/patina/operations/entities.rb

require 'patina/operations'

module Patina::Operations
  # Namespace for operations that act on an entity or collection of entities.
  module Entities
    autoload :AssignOneOperation,
      'patina/operations/entities/assign_one_operation'
    autoload :BuildOneOperation,
      'patina/operations/entities/build_one_operation'
    autoload :DestroyOneOperation,
      'patina/operations/entities/destroy_one_operation'
    autoload :FindManyOperation,
      'patina/operations/entities/find_many_operation'
    autoload :FindMatchingOperation,
      'patina/operations/entities/find_matching_operation'
    autoload :FindOneOperation,
      'patina/operations/entities/find_one_operation'
    autoload :InsertOneOperation,
      'patina/operations/entities/insert_one_operation'
    autoload :UpdateOneOperation,
      'patina/operations/entities/update_one_operation'
    autoload :ValidateOneOperation,
      'patina/operations/entities/validate_one_operation'
    autoload :ValidateOneUniquenessOperation,
      'patina/operations/entities/validate_one_uniqueness_operation'
  end # module
end # module
