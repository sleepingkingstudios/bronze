# Bronze

A composable application toolkit, providing data entities and collections, transforms, contract-based validations and pre-built operations. Architecture agnostic for easy integration with other toolkits or frameworks.

Bronze defines the following components:

- [Entities](#label-Entities) - Data structures with defined attributes.

## About

[comment]: # "Status Badges will go here."

### Compatibility

Cuprum is tested against Ruby (MRI) 2.3 through 2.5.

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

## Entities

    require 'bronze/entity'

An entity is a data object. Each entity class can define [attributes](#label-Entities-3A+Attributes).

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
