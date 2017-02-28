# Development

## Bug Fixes

- FindManyOperation: |

  When a user calls a FindManyOperation with an array with duplicate primary
  keys, it should call #uniq! on the array before comparing expected and actual
  resource counts. Otherwise, we get a false negative when all expected
  resources are found.

- Repository.collection:
  - use full name of entity to generate name: |

    Namespace::ModelName => 'namespace-model_name'

## MVP

## Features

- Association::Collection
  - dirty tracking
    - as above, plus #added, #removed ?
- Collection
  - bulk operations
  - #raw - returns clone with identity transform
  - use native data types where possible (BigDecimal, Date, etc)
  - Errors - use I18n-esque string values, not symbols
- Constraint
  - AttributeTypesConstraint
    - :except, :only ?
    - support attribute collections (use EachConstraint?)
- Contract
  - update syntax constrain :attribute, ClassName => true
    - if ClassName::Contract or ClassName::contract, uses contract
    - otherwise adds TypeConstraint => Class
  - add_constraint Publisher.contract, :each => :publisher # Like :on, but wraps in an EachConstraint
- Entity
  - associations
    - implicit inverse associations
    - nested attributes
    - builder methods - build_{association}, collection.build
    - query interface for _many associations?
  - attributes
    - Boolean attributes
      - defineable Boolean type - Bronze::Entities::Attributes::Boolean ?
      - predicate method
  - collection attributes
    - configuration option for restricting entity Hash attribute key types
      - options => String only, scalar only (String, Symbol, Integer?)
  - configuration option for default value of :allow_nil => default is true
  - dependent_attribute
    - creates read-only method on entity
    - collection writes the attribute but does not read it
  - dirty_tracking
    - #changes
    - #previous_changes
    - restore_{attribute}
    - restore_attributes
  - primary key types
    - AttributeMetadata#primary_key?
    - PrimaryKey::primary_key macro
    - PrimaryKey::Integer  # SQL
    - PrimaryKey::ObjectId # MongoDB
    - PrimaryKey::Ulid
    - ::foreign_key takes optional type argument
- Errors#first
- Operation
  - #always - always called, even if halted.
  - #halt!, #halted? - prevent further #then, #else callbacks.
- Query
  - #all returns with JSON envelope for advanced features?
  - #matching with non-equality predicates
    - use block syntax+DSL: |

      query = collection.matching do
        {
          :title => not_null,
          :author => not_equal('Ayn Rand'),
          :page_count => greater_than(10),
          :published_at => between(1.year.ago, Time.current)
        }
      end # matching

      # BUILDER ONLY, must convert to a Hash syntax!
    - not equal
    - not null
    - greater than (or equal to)
    - less than (or equal to)
    - between
    - before (alias less than?)
    - after (alias greater than?)
    - in (element is in array)
    - not in
    - full word converts to shorthand: __not_equal(_to) => :ne
  - #order
  - #includes
- Repository#except, #only - returns a copy of the repository that only has the given collections.
- Scope |

  ActivatedScope.new(params).call(query)
  #=> returns query.matching(:active => true)

- Single Table Inheritance
  - #types attribute?
- Ulid
  - automatically freeze after generation?
- bronze/rails
- bronze/forge
  - FactoryGirl syntax?

## Chores

- integration tests
  - collections
    - transforms
  - entities
    - associations
    - attributes
    - contracts
  - operations
- Documentation Pass
- Extract Bronze::Ci to standalone gem.
- Extract Patina::Collections::Mongo to standalone gem.
  - Test against MongoDB 2.x, 3.x
- remove `result, errors =` pattern?
- remove unnecessary custom error classes
- standardize error constant names - _ERROR suffix?

## Optimization

- benchmarks!!!
- reduce object allocation
  - stateless constraints? e.g. instead of TypeConstaint.new(klass).match(obj), TypeConstaint.match(obj, klass)
  - or ::instance
