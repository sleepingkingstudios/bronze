# Development

## Collections

### Advanced Querying

- Mongo-style selectors - query.matching(year: { $gt: 1986 }): |
  see https://docs.mongodb.com/manual/reference/operator/query/

  Comparison:
    $eq   Matches values that are equal to a specified value.
    $ne   Matches all values that are not equal to a specified value.
    $gt   Matches values that are greater than a specified value.
    $gte  Matches values that are greater than or equal to a specified value.
    $lt   Matches values that are less than a specified value.
    $lte  Matches values that are less than or equal to a specified value.
    $in   Matches any of the values specified in an array.
    $nin  Matches none of the values specified in an array.

  Element:
    $exists   Matches documents that have the specified field.
    $type   Selects documents if a field is of the specified type.

- Additional selectors: |
  see https://docs.mongodb.com/manual/reference/operator/query/

  Logical:
    $and  Joins query clauses with a logical AND returns all documents that match the conditions of both clauses.
    $not  Inverts the effect of a query expression and returns documents that do not match the query expression.
    $nor  Joins query clauses with a logical NOR returns all documents that fail to match both clauses.
    $or   Joins query clauses with a logical OR returns all documents that match the conditions of either clause.

  Evaluation:
    $mod  Performs a modulo operation on the value of a field and selects documents with a specified result.
    $regex  Selects documents where values match a specified regular expression.
    $text   Performs text search.

  Array:
    $all  Matches arrays that contain all elements specified in the query.
    $size   Selects documents if the array field is a specified size.

  Bitwise:
    $bitsAllClear   Matches numeric or binary values in which a set of bit positions all have a value of 0.
    $bitsAllSet   Matches numeric or binary values in which a set of bit positions all have a value of 1.
    $bitsAnyClear   Matches numeric or binary values in which any bit from a set of bit positions has a value of 0.
    $bitsAnySet   Matches numeric or binary values in which any bit from a set of bit positions has a value of 1.

- Nested querying:
  { key: { subkey: value } }
  { key: { subkey: { $eq => value } } }

### Transforms

Collection#transform

- configurable - repository.collection(definition, transform:)
- defaults to nil
- if definition is an Entity class, transform defaults to NormalizeTransform

## Entities

### Attributes

#### Boolean attributes

- attribute :flag, Boolean, default: false

- also generates #flag? predicate

#### :default option

- default value method: |
  #default_introduction => 'It was a dark and stormy night...'

- update #set_attribute to use default value unless allow_nil is true ?

- default proc can call instance methods: |
    attribute :serial_id, String, default: -> { generate_serial_id }

    also applies to Primary Key generation
- default proc that uses existing attributes: |
    attribute :full_name, String, default:
      ->(user) { [user.first_name, user.last_name].compact.join(' ') }

#### :enum option

- Unmapped: |
    attribute :rarity, String, enum: %w(rare medium well)

    Entity::RARITY => %w(rare medium well)
    Entity::RARITY::WELL => 'well'
    entity.attributes[:rarity] => 'well'
    entity.normalize => { rarity: 'well' }

- Mapped: |
    attribute :power_level, Integer,
      enum: { basic: 1, spinal_tap: 11, memetic: 9001 }

    Entity::POWER_LEVEL => { basic: 1, spinal_tap: 11, memetic: 9001 }
    Entity::POWER_LEVEL::MEMETIC => 9001
    entity.attributes[:power_level] => 9001
    entity.power_level => 'memetic'
    entity.normalize => { power_level: 9001 }

    Integration spec:
      class PlayingCard
        attribute :suit,
          String,
          enum: %w[clubs diamonds hearts spades]
        attribute :value,
          Integer,
          enum: {
            ace:   1,
            two:   2,
            ...
            ten:   10,
            jack:  11,
            king:  12,
            queen: 13
          }
      }
      end

#### :visible option

- attribute :hidden, String, visible: false
- defaults to true
- if visible: false:
    - do not include in #attributes
    - make getter, setter private
    - do include in normalize-denormalize

## Errors

- messages -> I18N?

## Transforms

- Rename #normalize to #call, #denormalize to #reverse_call ?
- JSON transform - to/from JSON string
- Reversible transforms
  - #reverse
  - Returns ReversedTransform
    - wraps transform
    - swaps #normalize, #denormalize
    - #reverse just returns original transform
- Irreversible transforms
