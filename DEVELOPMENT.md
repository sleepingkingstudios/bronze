# Development

- Documentation Pass
- Extract Bronze::Ci to standalone gem.
- remove `result, errors =` pattern?

## Bug Fixes

## Features

- Collection
  - bulk operations
- Constraint
  - AttributeTypesConstraint # :except, :only?
  - EachConstraint # wraps another constraint, matches it against each array item
- Contract
  - update syntax constrain :attribute, ClassName => true
    - if ClassName::Contract or ClassName::contract, uses contract
    - otherwise adds TypeConstraint => Class
  - add_constraint Publisher.contract, :each => :publisher # Like :on, but wraps in an EachConstraint
- Entity
  - configuration option for default value of :allow_nil => default is true
  - dependent_attribute
    - creates read-only method on entity
    - collection writes the attribute but does not read it
  - dirty_tracking
    - #changed? - alias #dirty?
    - #{attribute}_changed?
    - #old_{attribute}
    - #clean!
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
- Relations
  - Entities
    - foreign_key => attribute
    - Bronze::Entities::Relations::Metadata
    - relation macros
    - nested attributes
- Repository#except, #only - returns a copy of the repository that only has the given collections.
- Scope |

  ActivatedScope.new(params).call(query)
  #=> returns query.matching(:active => true)

- Single Table Inheritance
  - #types attribute?
- bronze/rails

## Optimization

- benchmarks!!!
- stateless constraints? e.g. instead of TypeConstaint.new(klass).match(obj), TypeConstaint.match(obj, klass)
