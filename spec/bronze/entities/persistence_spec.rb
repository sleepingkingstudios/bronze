# spec/bronze/entities/persistence_spec.rb

require 'bronze/entities/base_entity'
require 'bronze/entities/persistence'
require 'bronze/entities/persistence_examples'

RSpec.describe Bronze::Entities::Persistence do
  include Spec::Entities::PersistenceExamples

  let(:described_class) do
    Class.new(Bronze::Entities::BaseEntity) do
      include Bronze::Entities::Persistence
    end # described_class
  end # let
  let(:attributes) { {} }
  let(:instance)   { described_class.new attributes }

  include_examples 'should implement the Persistence methods'
end # describe
