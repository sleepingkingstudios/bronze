# lib/patina/collections/mongo/primary_key_transform.rb

require 'bronze/transform'

require 'patina/collections/mongo'

module Patina::Collections::Mongo
  # Transform to format the primary key entry for MongoDB.
  class PrimaryKeyTransform < Bronze::Transform
    # (see Bronze::Transform#denormalize)
    def denormalize hsh
      return hsh unless hsh.is_a?(Hash)

      hsh = hsh.dup

      hsh['id'] = hsh.delete '_id' if hsh.key?('_id')

      hsh
    end # method denormalize

    # (see Bronze::Transform#normalize)
    def normalize hsh
      return hsh unless hsh.is_a?(Hash)

      hsh = hsh.dup

      hsh['_id'] = hsh.delete 'id' if hsh.key?('id')

      hsh[:_id]  = hsh.delete :id  if hsh.key?(:id)

      hsh
    end # method normalize
  end # class
end # module
