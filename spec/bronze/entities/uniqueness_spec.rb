# spec/bronze/entities/uniqueness_spec.rb

require 'bronze/entities/attributes'
require 'bronze/entities/base_entity'
require 'bronze/entities/primary_key'
require 'bronze/entities/uniqueness'
require 'bronze/entities/uniqueness_examples'

RSpec.describe Bronze::Entities::Uniqueness do
  include Spec::Entities::UniquenessExamples

  let(:described_class) do
    Class.new(Bronze::Entities::BaseEntity) do
      include Bronze::Entities::Attributes
      include Bronze::Entities::PrimaryKey
      include Bronze::Entities::Uniqueness
    end # class
  end # let
  let(:entity_class) { described_class }
  let(:attributes)   { {} }
  let(:instance)     { entity_class.new attributes }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe

  include_examples 'should implement the Uniqueness methods'
end # describe
