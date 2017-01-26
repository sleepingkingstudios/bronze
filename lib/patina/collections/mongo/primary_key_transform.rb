# lib/patina/collections/mongo/primary_key_transform.rb

require 'bronze/transforms/transform'

require 'patina/collections/mongo'

module Patina::Collections::Mongo
  # Transform to format the primary key entry for MongoDB.
  class PrimaryKeyTransform < Bronze::Transforms::Transform
    # (see Bronze::Transforms::Transform#denormalize)
    def denormalize hsh
      hsh = hsh.dup

      hsh['id'] = hsh.delete '_id' if hsh.key?('_id')

      hsh
    end # method denormalize

    # (see Bronze::Transforms::Transform#normalize)
    def normalize hsh
      hsh = hsh.dup

      hsh['_id'] = hsh.delete 'id' if hsh.key?('id')

      hsh[:_id]  = hsh.delete :id  if hsh.key?(:id)

      hsh
    end # method normalize
  end # class
end # module
