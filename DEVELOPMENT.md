# Development

## Bug Fixes

- bronze/entities/transforms/entity_transform should require bronze/entities/transforms FIXED
- SimpleCollection#pluck does not work with a transform FIXED

## Features

- Query
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
- Operation
- Repository#except, #only - returns a copy of the repository that only has the given collections.
- Scope |

  ActiveScope.new(params).call(query)
  #=> returns query.matching(:active => true)

- bronze/rails
