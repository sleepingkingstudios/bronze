# Bronze

A composable application toolkit, providing data entities and collections, transforms, contract-based validations and pre-built operations. Architecture agnostic for easy integration with other toolkits or frameworks.

Bronze defines the following components:

- [Entities](#label-Entities) - Data structures with defined attributes.

## About

[comment]: # "Status Badges will go here."

### Compatibility

Bronze is tested against Ruby (MRI) 2.3 through 2.5.

### Documentation

Method and class documentation is available courtesy of [RubyDoc](http://www.rubydoc.info/github/sleepingkingstudios/bronze/master).

Documentation is generated using [YARD](https://yardoc.org/), and can be generated locally using the `yard` gem.

### License

Copyright (c) 2018 Rob Smith

Bronze is released under the [MIT License](https://opensource.org/licenses/MIT).

### Contribute

The canonical repository for this gem is located at https://github.com/sleepingkingstudios/bronze.

To report a bug or submit a feature request, please use the [Issue Tracker](https://github.com/sleepingkingstudios/bronze/issues).

To contribute code, please fork the repository, make the desired updates, and then provide a [Pull Request](https://github.com/sleepingkingstudios/bronze/pulls). Pull requests must include appropriate tests for consideration, and all code must be properly formatted.

### Dedication

This project is dedicated to the memory of my grandfather, who taught me the joy of flight.

## Entities

    require 'bronze/entity'

An entity is a data object. Each entity class can define [attributes](#label-Entities-3A+Attributes), including a [primary key](#label-Primary+Keys). Entities can be [normalized](#label-Normalization), which transforms the entity to a hash of data values or vice versa.

    class Book < Bronze::Entity
      attribute :title, String
    end

    # Creating an entity.
    book = Book.new
    book.title => nil

    # Creating an entity with attributes.
    book = Book.new(title: 'The Hobbit')
    book.title => 'The Hobbit'

    # Updating an entity's attributes.
    book.title = 'The Silmarillion'
    book.title => 'The Silmarillion'

### Attributes

    require 'bronze/entities/attributes'

An entity class defines zero or more attributes, which represent the data stored in the entity. Each attribute has a name, a type, and properties, which are stored as metadata and determine how the attribute is read and updated.

You can also define a thin entity class by including the Attributes module:

    class ThinEntity
      include Bronze::Entities::Attributes
    end

#### ::attribute Class Method

The `::attribute` class method is used to define attributes for an entity class. For example, the following code defines the `:title` entity for our `Book` entity class.

    class Book < Bronze::Entity
      attribute :title, String
    end

The `::attribute` method requires, at minimum, the name of the attribute (can be either a String or Symbol) and the type of the attribute value. The name determines how the attribute can be read and written. For example, since we have defined a `:title` attribute on `Book`, then each instance of `Book` will have a `#title` reader and a `#title=` writer method.

The attribute type is used for validations, and when normalizing or denormalizing the entity data.

You can pass additional options to `::attribute`; see below, starting at [:allow_nil Option](#label-3Aallow_nil+Option).

#### ::attributes Class Method

The attributes defined for an entity class are stored as metadata, and is accessible via the `::attributes` class method. This method returns a hash, with the attribute name (as a Symbol) as the hash key and a value of the corresponding metadata. For our Book class, this will look like the following.

    # Listing all defined attributes.
    Book.attributes => { title: #<Bronze::Entities::Attributes::Metadata> }

    # Metadata for a specific attribute.
    metadata = Book.attributes[:title]
    metadata.name    #=> :title
    metadata.type    #=> String
    metadata.options #=> {}

The metadata also provides helper methods for the attribute options:

    metadata = Book.attributes[:title]
    metadata.allow_nil? #=> false
    metadata.default?   #=> false
    metadata.read_only? #=> false

#### ::each_attribute Class Method

As an alternative, the `::each_attribute` method allows you to iterate through the attributes defined for an entity class. If no block is given, it returns an Enumerator, otherwise, it yields the name and metadata of each defined attribute to the block.

    Book.each_attribute { |name, metadata| puts name, metadata.options }

Using `::each_attribute` is recommended over `::attributes` where possible.

#### #== Operator

An entity can be compared with other entities or with a hash of attributes.

If the entity is compared to a hash, then the `#==` operator will return true if the hash is equal to the entity's attributes.

    book = Book.new(title: 'The Hobbit')
    book == {}                            #=> false
    book == { title: 'The Silmarillion' } #=> false
    book == { title: 'The Hobbit' }       #=> true

If the entity is compared to another object, then the `#==` operator will return true if and only if the other object has the same class (not a subclass) and the same attributes.

    # Comparing with the same class but different attributes.
    book == Book.new #=> false

    # Comparing with a different class but the same attributes.
    book == Periodical.new(title: 'The Hobbit') #=> false

    # Comparing with the same class and attributes.
    book == Book.new(title: 'The Hobbit') #=> true

#### #assign_attributes Method

The `#assign_attributes` method updates the entity with the given attributes. Any attributes that are not in the given hash are unchanged, as are any attributes that are flagged as [read-only](#label-3Aread_only+Option).

    class Book < Bronze::Entity
      attribute :title,    String
      attribute :subtitle, String
      attribute :isbn,     String, read_only: true
    end

    book = Book.new(
      title:    'The Hobbit',
      subtitle: 'There And Back Again',
      isbn:     '123-4-56-789012-3'
    )
    book.assign_attributes(
      subtitle: 'The Desolation of Smaug',
      isbn:     '098-7-65-432109-8'
    )

    # The title is unchanged because it was not in the attributes hash.
    book.title #=> 'The Hobbit'

    # The subtitle is updated.
    book.subtitle #=> 'The Desolation of Smaug'

    # The ISBN is unchanged because it is read-only.
    book.isbn #=> '123-4-56-789012-3'

If the hash includes keys that do not correspond to attributes, it will raise an ArgumentError.

    book.assign_attributes(banned_date: Date.today) #=> raises ArgumentError

#### #attribute? Method

The `#attribute?` method tests whether the entity defines the given attribute, which can be either a String or Symbol.

    class Book < Bronze::Entity
      attribute :title, String
    end

    book = Book.new

    # With a valid attribute name.
    book.attribute?('title') #=> true
    book.attribute?(:title)  #=> true

    # With an invalid attribute name.
    book.attribute?(:banned_date) #=> false

#### #attributes Method

The `#attributes` method returns the current values of each defined attribute.

    class Book < Bronze::Entity
      attribute :title, String
    end

    book = Book.new
    book.attributes #=> { title: nil }

    book = Book.new(title: 'The Hobbit')
    book.attributes #=> { title: 'The Hobbit' }

#### #attributes= Method

The `#attributes=` method sets the attributes to the given hash, even if the attribute is flagged as read-only. Any attributes that are not in the hash are set to nil.

Generally, the `#assign_attributes` method is preferred for updating attributes.

    class Book < Bronze::Entity
      attribute :title,    String
      attribute :subtitle, String
      attribute :isbn,     String, read_only: true
    end

    book = Book.new(
      title:    'The Hobbit',
      subtitle: 'There And Back Again',
      isbn:     '123-4-56-789012-3'
    )
    book.attributes = {
      subtitle: 'The Desolation of Smaug',
      isbn:     '098-7-65-432109-8'
    }

    # The title is set to nil because it was not in the attributes hash.
    book.title #=> nil

    # The subtitle is updated.
    book.subtitle #=> 'The Desolation of Smaug'

    # The ISBN is updated, even though it is read-only.
    book.isbn #=> '098-7-65-432109-8'

If the hash includes keys that do not correspond to attributes, it will raise an ArgumentError.

    book.attributes = { banned_date: Date.today } #=> raises ArgumentError

#### #get_attribute Method

The `#get_attribute` method returns the current value of the given attribute, which can be either a String or a Symbol.

  class Book < Bronze::Entity
    attribute :title, String
  end

  book = Book.new(title: 'The Hobbit')
  book.get_attribute('title') => 'The Hobbit'
  book.get_attribute(:title)  => 'The Hobbit'

If the named attribute is not a valid attribute for the entity, it will raise an ArgumentError.

  book.get_attribute(:banned_date) #=> raises ArgumentError

#### #set_attribute Method

The `#set_attribute` method updates the attribute to the given value. The attribute name must be either a String or a Symbol.

  class Book < Bronze::Entity
    attribute :title, String
  end

  book = Book.new(title: 'The Hobbit')
  book.set_attribute(:title, 'The Silmarillion')
  book.title  => 'The Silmarillion'

If the named attribute is not a valid attribute for the entity, it will raise an ArgumentError.

  book.get_attribute(:banned_date, Date.today) #=> raises ArgumentError

#### :allow_nil Option

The `:allow_nil` option marks the attribute as permitting `nil` values. This flag is used in validations.

    class Book
      attribute :subtitle, String, allow_nil: true
    end

    metadata = Book.attributes[:subtitle]
    metadata.allow_nil? #=> true

#### :default Option

The `:default` option provides a default value or proc to pre-populate the attribute when creating an entity. Unless this option is used, the initial value of the entity will be `nil`.

When the default is a value, then new instances of the entity class will pre-populate the attribute with that value.

    class Book
      attribute :introduction,
        String,
        default: 'It was a dark and stormy night.'
    end

    book = Book.new
    book.introduction #=> 'It was a dark and stormy night.'

When the default is a block, then the block will be called each time the entity class is instantiated, setting the attribute to the value returned from the block.

    class Book
      next_index = 0

      attribute :index, Integer, default: -> { next_index += 1 }
    end

    book = Book.new
    book.index #=> 1

    book = Book.new
    book.index #=> 2

#### :read_only Option

The `:read_only` option marks the attribute as being read-only, i.e. written to only once (typically when the entity is initialized). An entity with this flag set will mark the writer method as private, and will not be updated by the `#assign_attributes` or `#set_attribute` methods.

    class Book
      attribute :isbn, String, read_only: true
    end

    metadata = Book.attributes[:isbn]
    metadata.read_only? #=> true

    book = Book.new(isbn: '123-4-56-789012-3')
    book.isbn #=> '123-4-56-789012-3'

    # Setting the value with a writer method.
    book.isbn = '098-7-65-432109-8' #=> raises NoMethodError

    # Setting the value with #assign_attributes.
    book.assign_attributes(isbn: '098-7-65-432109-8')
    book.isbn #=> '123-4-56-789012-3'

    # Setting the value with #set_attribute.
    book.set_attribute(:isbn, '098-7-65-432109-8')
    book.isbn #=> '123-4-56-789012-3'

#### :transform Option

The `:transform` option sets the transform used to convert the attribute to and
from a normal form. This is used for normalization, e.g. converting the entity to a portable form, and for serializing the entity to and from a data store.

Most attributes do not require a transform, and are unchanged during normalization/serialization since most data stores will natively support that data type. For select builtin types, there are default transforms defined (see [Attribute Transforms](#label-Attribute+Transforms), below). Finally, the `:transform` option lets you set the transform for the current attribute, whether that is to override an existing default or to support a custom data type.

    class Point < Struct.new(:x, :y)

    class PointTransform < Bronze::Transform
      def denormalize(coords)
        Point.new(*Array(coords))
      end

      def normalize(point)
        [point.x, point.y]
      end
    end

    class Map
      attribute :treasure, Point, transform: PointTransform
    end

    point = Point.new(3, 4)
    map   = Map.new(point: point)

### Normalization

    require 'bronze/entities/normalization'

An entity class can define normalization helper methods, which convert an entity to a hash of data values and vice versa.

A normalized value is one of the following:

- A literal value:
    - `nil`
    - `true` or `false`
    - A `String`
    - An `Integer`
    - A `Float`
- An `Array` of normalized items
- A `Hash` with `String` keys and with normalized values

Any other values should be converted to a normalized value, e.g. by setting a [:transform option](#label-3Atransform+Option) when defining the attribute.

#### ::denormalize Class Method

The `::denormalize` class method converts a normalized hash to an entity instance.

    class Book < Bronze::Entity
      attribute :title,    String
      attribute :subtitle, String, allow_nil: true
      attribute :isbn,     String, read_only: true
    end

    attributes = {
      title: 'Journey To The West',
      isbn:  '123-4-56-789012-3'
    }
    book = Book.denormalize(attributes)
    book.class    #=> Book
    book.title    #=> 'Journey To The West'
    book.subtitle #=> nil
    book.isbn     #=> '123-4-56-789012-3'

When an attribute has a defined transform (either from an [attribute transform](#label-Attribute+Transforms) or by defining the [:transform option](#label-3Atransform+Option)), then that transform is used when creating the entity from the data hash.

    class Periodical
      attribute :title, String
      attribute :issue, Integer
      attribute :date,  DateTime
    end

    attributes = {
      title: 'Triskadecaphobia Today',
      issue: 13,
      date:  '2013-10-03T13:13:13+1300'
    }
    periodical = Periodical.denormalize(attributes)
    periodical.class #=> Periodical
    periodical.title #=> 'Triskadecaphobia Today'
    periodical.issue #=> 13
    periodical.date  #=> #<DateTime: 2013-10-03T13:13:13+13:00>

#### #normalize Method

The `#normalize` method converts an entity instance to a normalized hash.

    class Book < Bronze::Entity
      attribute :title,    String
      attribute :subtitle, String, allow_nil: true
      attribute :isbn,     String, read_only: true
    end

    attributes = {
      title: 'Journey To The West',
      isbn:  '123-4-56-789012-3'
    }
    book = Book.new(attributes)
    hash = book.normalize
    hash.class       #=> Hash
    hash['title']    #=> 'Journey To The West'
    hash['subtitle'] #=> nil
    hash['isbn']     #=> '123-4-56-789012-3'

When an attribute has a defined transform (either from an [attribute transform](#label-Attribute+Transforms) or by defining the [:transform option](#label-3Atransform+Option)), then that transform is used when generating the entity from the data hash.

    class Periodical
      attribute :title, String
      attribute :issue, Integer
      attribute :date,  DateTime
    end

    attributes = {
      title: 'Triskadecaphobia Today',
      issue: 13,
      date:  #<DateTime: 2013-10-03T13:13:13+13:00>
    }
    periodical = Periodical.new(attributes)
    hash       = periodical.normalize
    hash.class    #=> Hash
    hash['title'] #=> 'Triskadecaphobia Today'
    hash['issue'] #=> 13
    hash['date']  #=> '2013-10-03T13:13:13+1300'

### Primary Keys

    require 'bronze/entities/primary_key'

An entity class can define a primary key attribute, which serves as a unique identifier for each entity. A primary key never allows for `nil` values, is `read-only`, and has additional protections against being overwritten (for example, by the `#attributes=` method).

Since the primary key is an attribute, defining a primary key requires both the Attributes module and the PrimaryKey module.

    class ThinEntity
      include Bronze::Entities::Attributes
      include Bronze::Entities::PrimaryKey
    end

Some predefined primary key solutions are available; see below, starting at [PrimaryKeys: UUID](#label-Primary+Keys-3A+UUID).

#### ::define_primary_key Class Method

The `::define_primary_key` class method is used to define a primary key for an entity class and its descendants.

    class Book
      define_primary_key :id, String, default: -> { SecureRandom.uuid }
    end

As with defining an attribute, defining a primary key requires the name and object type of the key. In addition, a default block must be provided for generating the primary key. In this case, we are setting the primary key to `:id`, which is a `String` generated by calling `SecureRandom.uuid`. This value is automatically generated when the entity is instantiated, unless an `id` value is explicitly passed into `::new`.

Internally, this delegates to calling `::attribute`. This means our `#id` accessor is defined for us (but not `#id=`, since the primary key is read-only). Like any other attribute, the primary key will appear in `#attributes`, can be accessed via `#get_attribute`, and we can access the metadata via the `::attributes` class method.

#### ::primary_key Class Method

The `::primary_key` class method returns the metadata for our primary key attribute directly, without having to go through `::attributes`. This will return an instance of `Bronze::Entities::Attributes::Metadata` If a primary key is not defined for the entity class, it will return `nil`.

For example, the following code will return the name of the primary key for our Book class:

    Book.primary_key.name

#### #primary_key Method

The `#primary_key` method returns the value of the primary key for the entity. This can be useful when different entities may use different attributes as their primary keys, such as applications using multiple datastores or with legacy data.

    book = Book.new(id: '7c582500-2b33-4b41-bffc-68231c23949a')
    book.id          #=> '7c582500-2b33-4b41-bffc-68231c23949a'
    book.primary_key #=> '7c582500-2b33-4b41-bffc-68231c23949a'

### Primary Keys: UUID

    require 'bronze/entities/primary_keys/uuid'

A common format for primary keys is the UUID, or Universally unique identifier (also known as the GUID). Each UUID is unique for all practical purposes, even distributed across different servers or processes.

The `PrimaryKeys::Uuid` module simplifies defining a UUID-based primary key by overriding the `::define_primary_key` class method (see below). It can be included in a subclass of `Bronze::Entity`, or directly in any class that includes `Bronze::Entities::Attributes`.

    # Including in a subclass of Bronze::Entity.
    class Book < Bronze::Entity
      include Bronze::Entities::PrimaryKeys::Uuid
    end

    # Including directly in a custom entity class.
    class Periodical
      include Bronze::Entities::Attributes
      include Bronze::Entities::PrimaryKeys::Uuid
    end

A UUID is represented in Bronze by its string representation, which looks something like this: `"6891120c-c018-4060-a8b1-22d0278003f8"`. Generation is delegated to the `SecureRandom.uuid` method.

#### ::define_primary_key Class Method

The `::define_primary_key` class method is used to define a UUID primary key. Both the object type and the default generation are handled, so all that is required is the name of the primary key.

    class Book < Bronze::Entity
      include Bronze::Entities::PrimaryKeys::Uuid

      define_primary_key :id
    end

## Transforms

    require 'bronze/transform'

A transform represents a mapping between one type of object to another.

    class Point < Struct.new(:x, :y)

    class PointTransform < Bronze::Transform
      def denormalize(coords)
        Point.new(*Array(coords))
      end

      def normalize(point)
        [point.x, point.y]
      end
    end

    point     = Point.new(3, 4)
    transform = PointTransform.new
    transform.normalize(point)
    #=> [3, 4]

    point = transform.denormalize([5, 12])
    point.class
    #=> Point
    point.x
    #=> 5
    point.y
    #=> 12

Transforms can be either mono- or bi-directional.

    class UpcaseTransform < Bronze::Transform
      # No denormalize method is defined, since this not reversible.

      def normalize(string)
        string.upcase
      end
    end

    transform = UpcaseTransform
    transform.normalize('lower case string')
    #=> 'LOWER CASE STRING'

    transform.denormalize('UPPER CASE STRING')
    #=> raises NotImplementedError

### Methods

Each transform must define the `#normalize` and `#denormalize` methods. Transforms that inherit from Bronze::Transform will raise a `NotImplementedError` unless those methods are redefined.

#### ::instance Class Method

Optional. An `::instance` class method is recommended For transforms that take no arguments and have no internal state. `::instance` should memoize a call to `::new` and return the same transform instance each time it is called to minimize object allocation and memory usage.

    class CaseTransform
      def self.instance
        @instance ||= new
      end
    end

    transform = CaseTransform.instance

If the transform does have internal state, e.g. stores values with instance variables, an alternative might be to use a thread-local instance.

#### #denormalize Method

The `#denormalize` method converts the object or data back from an alternate form. This should be the inverse of the `#normalize` method (see below).

    transform = CaseTransform.new
    transform.denormalize('lower case string')
    #=> 'LOWER CASE STRING'

For one-way transforms, the `#denormalize` method should raise a `NotImplementedError`.

#### #normalize Method

The `#normalize` method converts the object or data to an alternate form. By convention, the normalized result is a simpler or standardized form, such as converting an entity to a hash of attributes.

    transform = CaseTransform.new
    transform.normalize('UPPER CASE STRING')
    #=> 'upper case string'

For one-way transforms, use the `#normalize` method to transform the data.

### Attribute Transforms

Transforms can be used to serialize and store custom attributes (see [:transform Option](#label-3Atransform+Option), above). Each attribute transform converts the value to an easily-stored form with `#normalize` and restores the original form with `#denormalize`.

#### BigDecimalTransform

    require 'bronze/transforms/attributes/big_decimal_transform'

Converts a BigDecimal to a string representation.

    transform = Bronze::Transforms::Attributes::BigDecimalTransform.instance
    transform.normalize(BigDecimal('3.14'))
    #=> '3.14'

    decimal = transform.denormalize('3.14')
    decimal.class
    #=> BigDecimal
    decimal.to_f
    #=> 3.14

#### DateTimeTransform

    require 'bronze/transforms/attributes/date_time_transform'

Converts a DateTime to a string representation. By default, uses an ISO 8601 string format.

    transform = Bronze::Transforms::Attributes::DateTimeTransform.instance
    date_time = DateTime.new(1982, 7, 9, 12, 30, 0)
    transform.normalize(date)
    #=> '1982-07-09T12:30:00+0000'

    date_time = transform.denormalize('1982-07-09T12:30:00+0000')
    date_time.class
    #=> DateTime
    date_time.year
    #=> 1982
    date_time.hour
    #=> 12
    date_time.zone
    #=> '+00:00'

By passing an optional format parameter, the transform can serialize to and from an alternate string format. Not all possible formats are guaranteed to work with both `#normalize` and `#denormalize`, however, and custom formats may not ensure that all data from the date is stored in the serialized string.

    format    = '%B %-d, %Y at %T'
    transform = Bronze::Transforms::Attributes::DateTimeTransform.new(format)
    date_time = DateTime.new(1982, 7, 9, 12, 30, 0)
    transform.normalize(date_time)
    #=> 'July 9, 1982 at 12:30:00'

    date_time = transform.denormalize('July 9, 1982 at 12:30:00')
    date_time.class
    #=> DateTime
    date_time.year
    #=> 1982
    date_time.hour
    #=> 12
    date_time.zone
    #=> '+00:00'

#### DateTransform

    require 'bronze/transforms/attributes/date_transform'

Converts a Date to a string representation. By default, uses an ISO 8601 string format.

    transform = Bronze::Transforms::Attributes::DateTransform.instance
    date      = Date.new(1982, 7, 9)
    transform.normalize(date)
    #=> '1982-07-09'

    date = transform.denormalize('1982-07-09')
    date.class
    #=> DateTime
    date.year
    #=> 1982
    date.month
    #=> 7
    date.day
    #=> 9

By passing an optional format parameter, the transform can serialize to and from an alternate string format. Not all possible formats are guaranteed to work with both `#normalize` and `#denormalize`, however, and custom formats may not ensure that all data from the date is stored in the serialized string.

    format    = '%B %-d, %Y'
    transform = Bronze::Transforms::Attributes::DateTransform.new(format)
    date      = Date.new(1982, 7, 9)
    transform.normalize(date)
    #=> 'July 9, 1982'

    date = transform.denormalize('July 9, 1982')
    date.class
    #=> DateTime
    date.year
    #=> 1982
    date.month
    #=> 7
    date.day
    #=> 9

#### SymbolTransform

    require 'bronze/transforms/attributes/symbol_transform'

Converts a Symbol to a string representation.

    transform = Bronze::Transforms::Attributes::SymbolTransform.instance
    transform.normalize(:symbol_value)
    #=> 'symbol_value'
    transform.denormalize('string_value')
    #=> :string_value

#### TimeTransform

    require 'bronze/transforms/attributes/time_transform'

Converts a Time to an integer representation.

    transform = Bronze::Transforms::Attributes::SymbolTransform.instance
    time      = Time.new(1982, 7, 9)
    transform.normalize(time)
    #=> 395035200

    time = transform.denormalize(395035200)
    time.class
    #=> Time
    time.year
    #=> 1982
    time.hour
    #=> 0
