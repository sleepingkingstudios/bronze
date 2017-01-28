# spec/support/mongo.rb

require 'mongo'

module Spec
  def self.mongo_client
    Mongo::Logger.logger.level = ::Logger::WARN

    @mongo_client ||=
      ::Mongo::Client.new('mongodb://127.0.0.1:27017/patina_test')
  end # method mongo_client
end # module
