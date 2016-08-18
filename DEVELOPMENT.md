# The Apps Structure

/apps
  /cartographer # Defining, persisting Location entities.
    /location.rb
    /locations # Uses Dependency Injection to wrap a collection.
      /mappings
        /mapping.rb
      /create.rb # Builds and persists a Location based on the given params.
  /explorer # Navigating Location mesh; depends on cartographer, game definition.
/lib # Common classes, framework definitions.

# The Entity Ecosystem

An "Entity" is a domain object that has a number of properties, called "attributes". Entities also support reflection on their attributes.

A "Collection" is a reference to a datastore that persists entities of a given type. A collection can perform CRUD operations to persist and retrieve entities from the datastore that it wraps.

A "Query" is a read operation against a Collection. Queries are defined as a collection of Criteria, each of which defines a constraint on the returned data, such as "all records must match this title" or "records are returned in order of creation date". To optimize performance, queries are lazy and use cached values where possible.

A "Repository" is a reference to a datastore as a whole. Each repository can have many collections, representing different types of Entities, different tables or views (SQL), different collections (MongoDB), or even different representations of the same Entities.

A "Transform" converts an Entity into a data object writeable to a Collection, or a data object read from a Collection into an Entity. The default option is an AttributesTransform, which uses the attributes reflection of an Entity class.

database = SqlRepository.connect(options)
users = database.collection(:users, AttributesTransform.new(User))
# OR
users = database.collection(:users, User) # Uses default transform.
# OR
users = database.collection(:users) # Uses hash of basic types.

## File Structure

/apps
  /:application_name
    /:entity_name.rb
    /pluralize(:entity_name)
      /mappings
        /mapping.rb
      /:operation_name.rb
/lib
  /bronze
    /entities
    /repositories
      /collection.rb
      /repository.rb
      /:repository_name
        /collection.rb
        /queries
          /criterion.rb
        /query.rb