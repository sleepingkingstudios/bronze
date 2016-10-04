# Development

- Extract Bronze::Ci to standalone gem.

## Bug Fixes

## Features

- Errors#merge, #update
- Collection
  - bulk operations
- Constraint
  - represents an expectation on an object
  - Contract
    - group of constraints
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
- Repository#except, #only - returns a copy of the repository that only has the given collections.
- Scope |

  ActivatedScope.new(params).call(query)
  #=> returns query.matching(:active => true)

- bronze/rails
