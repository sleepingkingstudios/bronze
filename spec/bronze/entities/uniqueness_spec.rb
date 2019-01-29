# spec/bronze/entities/uniqueness_spec.rb

require 'bronze/entities/attributes'
require 'bronze/entities/base_entity'
require 'bronze/entities/primary_keys/uuid'
require 'bronze/entities/uniqueness'
require 'bronze/entities/uniqueness_examples'

RSpec.describe Bronze::Entities::Uniqueness do
  include Spec::Entities::UniquenessExamples

  let(:described_class) do
    Class.new(Bronze::Entities::BaseEntity) do
      include Bronze::Entities::Attributes
      include Bronze::Entities::PrimaryKeys::Uuid
      include Bronze::Entities::Uniqueness

      define_primary_key :id
    end # class
  end # let
  let(:entity_class)       { described_class }
  let(:initial_attributes) { {} }
  let(:instance)           { entity_class.new initial_attributes }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe

  include_examples 'should implement the Uniqueness methods'
end # describe
