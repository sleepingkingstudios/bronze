# Development

- Revisit Entity<->Operation interactions:

  Two "types" of EntityOperation:
  - abstract: |

    Takes an entity class as a constructor argument.

    E.g. ValidateOneOperation.new(Book).call(book)

  - concrete: |

    Defined with an entity class. Extends abstract class ?

    E.g. ValidateOneBookOperation.new.call(book)

    Or Book::Operations::ValidateOne ?

  Pre-defined chained operations for resourceful actions?
  - create => build, validate, validate_uniqueness, insert
  - update => assign, validate, validate_uniqueness, update

  Dual inheritance issue:
  - from the operation class
  - from common entity configuration

  Procedural Generation/Metaprogramming
  - shouldn't have to define each operation for each entity
  - should always have human readable name
  - should be easily open for extension, esp. chaining

  Coordinator object - Book::Operations?
  - use module builder pattern?
  - access as class:  Book::Operations::ValidateOne.new(book)
  - access as method: Book::Operations.validate_one(book)
  - defines DSL for adding, redefining operations:

    operation :validate_one, ValidateOneBookOperation

    operation :custom_operation do; end

  - ResourcefulOperationsCoordinator (rename pls) defines standard resourceful
    operations with single DSL (resource Book ?)

  Steps:

  ...

  3.  Create coordinator class/module - OperationBuilder

      class Book
        Operations = EntityOperationBuilder.new(self)
      end # class

      ::operation method: |

          operation :validate_one, ValidateOneBookOperation
          operation :custom_operation do; end

          Defines Book::Operations::ValidateOne, #validate_one.

  3A. Create entity operations class/module - EntityOperationBuilder.

      Takes entity class, builds default entity operations.

      ::entity_operations method

  4.  Create resourceful operations class/module - ResourceOperationGroup ?

      Belongs to Bronze::Rails !

      ::resource_operations method: |

          for each undefined entity operation:
          - defines class in namespace

            class Book::Operations::ValidateOne < ValidateOneOperation
              def initialize(*rest)
                super(Book, *rest)
              end # constructor
            end # class

## Bug Fixes

## MVP

## Code Cleanup

- Remove Constraint passed_errors pattern.
- Remove Operation#failure_message.

## Features

- Association
  - has_many should define #association_ids method
- Association::Collection
  - should define #ids method
  - dirty tracking
    - as attribute dirty tracking, plus #added, #removed ?
- Collection
  - bulk operations
  - #raw - returns clone with identity transform
  - use native data types where possible (BigDecimal, Date, etc)
  - Errors - use I18n-esque string values, not symbols
  - Query-like access to in-memory items?
- Constraint
  - AttributeTypesConstraint
    - :except, :only ?
    - support attribute collections (use EachConstraint?)
  - Error messages have configurable prefix: |

    def error_prefix
      'bronze.constraints.errors'
    end # method error_prefix

    Each constraint defines final segment:

    NOT_UNIQUE_ERROR = 'not_unique'

    Delegated to by standard private reader:

    def error_key
      NOT_UNIQUE_ERROR
    end # method error_key

    def error_message
      "#{error_prefix}.#{error_key}"
    end # method error_message
  - Aggregate constraints via chaining with #and, #or, #not?
- Contract
  - update syntax constrain :attribute, ClassName => true
    - if ClassName::Contract or ClassName::contract, uses contract
    - otherwise adds TypeConstraint => Class
  - add_constraint Publisher.contract, :each => :publisher # Like :on, but wraps in an EachConstraint
- Entitlement:

  super-charged permissions model? Superset of permissions?

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
  - primary key types
    - AttributeMetadata#primary_key?
    - PrimaryKey::primary_key macro
    - PrimaryKey::Integer  # SQL
    - PrimaryKey::ObjectId # MongoDB
    - PrimaryKey::Ulid
    - ::foreign_key takes optional type argument
  - human keys?
    - hash(primary_key) -> take first X*2^N bits
      - 7 4-bit hex chars (git rev?)
      - 5 32-bit chars (SHA-1?)
    - can be slug (see dependent_attribute)
- Errors#first
- Operations
  - #curry
  - #always,  #chain,  #else,  #then  return copies of chain w/ added operation/block
  - #always!, #chain!, #else!, #then! modify the current chain
- Query
  - #each with no block returns an enumerator
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
- Extract Patina::Collections::Mongo to standalone gem.
  - Test against MongoDB 2.x, 3.x
- remove `result, errors =` pattern?
- remove unnecessary custom error classes
- standardize error constant names - \_ERROR suffix?

## Optimization

- benchmarks!!!
  - performance
  - memory usage
- reduce object allocation
  - stateless constraints? e.g. instead of TypeConstaint.new(klass).match(obj), TypeConstaint.match(obj, klass)
  - or ::instance
