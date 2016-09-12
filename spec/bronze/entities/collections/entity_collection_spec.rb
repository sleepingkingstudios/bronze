# spec/bronze/entities/collections/entity_collection_spec.rb

require 'bronze/collections/collection'
require 'bronze/collections/collection_examples'
require 'bronze/entities/entity'
require 'bronze/entities/collections/entity_collection'
require 'bronze/entities/transforms/entity_transform'
require 'bronze/transforms/identity_transform'

RSpec.describe Bronze::Entities::Collections::EntityCollection do
  include Spec::Collections::CollectionExamples

  let(:entity_class_or_transform) do
    double('transform')
  end # let
  let(:described_class) do
    klass = Class.new do
      include Bronze::Collections::Collection
    end # class

    klass.send :include, super()

    klass
  end # let
  let(:instance) { described_class.new entity_class_or_transform }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#entity_class' do
    include_examples 'should have reader', :entity_class

    context 'when the instance is initialized with a transform' do
      let(:entity_class_or_transform) do
        Bronze::Transforms::IdentityTransform.new
      end # let

      it { expect(instance.entity_class).to be nil }

      # it { expect(instance.entity_class).to be entity_class_or_transform }
    end # context
  end # describe

  describe '#transform' do
    context 'when the instance is initialized with an entity class' do
      let(:entity_class_or_transform) do
        Class.new(Bronze::Entities::Entity) do
          attribute :title,  String
          attribute :author, String
        end # class
      end # let
      let(:transform_class) { Bronze::Entities::Transforms::EntityTransform }

      it 'should create a transform for the entity class' do
        entity_class = entity_class_or_transform
        transform    = instance.transform

        expect(transform).to be_a transform_class
        expect(transform.entity_class).to be entity_class
      end # it
    end # context

    context 'when the instance is initialized with a transform' do
      let(:entity_class_or_transform) do
        Bronze::Transforms::IdentityTransform.new
      end # let

      it { expect(instance.transform).to be entity_class_or_transform }
    end # context
  end # describe
end # describe
