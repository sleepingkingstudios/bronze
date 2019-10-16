# Changelog

## 0.2.0

### Collections

Adds the Bronze::Collection class, which represents a searchable set of entities.

#### Adapters

Each collection delegates to a Bronze::Collections::Adapter, which handles the wiring between the Collection interface and a specific data source such as a database or an in-memory data structure.

#### Queries

Each collection adapter defines a Query object, which provides a standardized interface for running queries against the underlying data.

#### Repositories

Collections are grouped together as a Bronze::Repository, which abstracts accessing multiple data streams from a single source, such as a database with multiple tables.

### Transforms

Implemented Transform composition via the #<< and #>> methods.

## 0.1.0

Initial release.

### Attributes

Adds the Bronze::Entities::Attributes module, which can be included in any class to define and use attribute properties. Attributes are defined by the ::attribute class method and accessed by getter and setter methods and/or the #attributes, #get_attribute and #set_attribute methods.

### Entities

Adds the Bronze::Entity class, which serves as an abstract base class for defining application entities. Includes the Attributes, Normalization, and PrimaryKey modules.

#### Normalization

Adds the Bronze::Entities::Normalization module, which can be included in any entity class to define normalization methods, which transform an entity class to a hash of data values and vice versa.

#### Primary Keys

Adds the Bronze::Entities::PrimaryKey module, which can be included in any entity class to define a primary key for the entity class.

Adds the Bronze::Entities::PrimaryKeys::Uuid module, which defines a UUID primary key for the entity class.

### Transforms

Adds the Bronze::Transform class, which provides an abstract base class for mono- or bi-directional data transformations.

Adds normalization transforms for the BigDecimal, DateTime, Date, Symbol and Time classes.

Adds normalization transform for entities.
