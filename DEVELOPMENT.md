# Development

## Collections

### Advanced Querying

- Mongo-style selectors - query.matching(year: { $gt: 1986 })

### Primary Keys

- configurable - repository.collection(definition, primary_key:)
- default to :id
- autodetect if definition is an entity class
- allows query.find()
- allows collection.find(id), collection.update(id, data), collection.delete(id)

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

- JSON transform - to/from JSON string
