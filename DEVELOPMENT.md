# Development

## Bug Fixes

## MVP

- Associations
  - Entities
    - Bronze::Entities::Associations::AssociationMetadata
    - Bronze::Entities::Associations::AssociationBuilder
    - relation macros - on Bronze::Entities::Associations module
    - references_one
    - has_one
    - has_many
    - implicit inverse associations
    - nested attributes
    - improve testing/validation around missing/mismatched inverse associations
      - inverse association expected but not defined
      - inverse association has incompatible type
      - inverse association already has other inverse
    - :foreign_key is private writer? Or clears association(s).

## Features

- Collection
  - bulk operations
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
    - query interface for _many associations?
  - attribute normalization (Symbol <=> String, etc)
  - collection attributes
    - configuration option for restricting entity Hash attribute key types
      - options => String only, scalar only (String, Symbol, Integer?)
  - configuration option for default value of :allow_nil => default is true
  - dependent_attribute
    - creates read-only method on entity
    - collection writes the attribute but does not read it
  - dirty_tracking
    - #changed? - alias #dirty?
    - #{attribute}_changed?
    - #old_{attribute}
    - #clean!
    - for _many attributes, track :added, :removed
  - primary key types
    - AttributeMetadata#primary_key?
    - PrimaryKey::primary_key macro
    - PrimaryKey::Integer  # SQL
    - PrimaryKey::ObjectId # MongoDB
    - PrimaryKey::Ulid
    - ::foreign_key takes optional type argument
- Errors#first
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
  - #order
  - #includes
- Repository#except, #only - returns a copy of the repository that only has the given collections.
- Scope |

  ActivatedScope.new(params).call(query)
  #=> returns query.matching(:active => true)

- Single Table Inheritance
  - #types attribute?
- bronze/rails

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
- remove `result, errors =` pattern?
- remove unnecessary custom error classes
- standardize error constant names - _ERROR suffix?

## Optimization

- benchmarks!!!
- stateless constraints? e.g. instead of TypeConstaint.new(klass).match(obj), TypeConstaint.match(obj, klass)
