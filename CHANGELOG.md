# Changelog

## 0.1.0

Initial release.

### Attributes

Adds the Bronze::Entity::Attributes module, which can be included in any class to define and use attribute properties. Attributes are defined by the ::attribute class method and accessed by getter and setter methods and/or the #attributes, #get_attribute and #set_attribute methods.

### Entities

Adds the Bronze::Entity class, which serves as an abstract base class for defining application entities. Includes the Attributes and PrimaryKey modules.

### Primary Keys

Adds the Bronze::Entity::PrimaryKey module, which can be included in any entity with attributes to define a primary key for the entity class.

Adds the Bronze::Entity::PrimaryKeys::Uuid module, which defines a UUID primary key for the entity class.

### Transforms

Adds the Bronze::Transform class, which provides an abstract base class for mono- or bi-directional data transformations. Adds normalization transforms for the BigDecimal, DateTime, Date, Symbol and Time classes.
