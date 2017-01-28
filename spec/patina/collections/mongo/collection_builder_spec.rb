# spec/patina/collections/mongo/collection_builder_spec.rb

require 'patina/collections/mongo/collection_builder'

RSpec.describe Patina::Collections::Mongo::CollectionBuilder do
  let(:mongo_client) { Spec.mongo_client }
  let(:collection_class) do
    Patina::Collections::Mongo::Collection
  end # let
  let(:collection_type) { :resources }
  let(:instance) do
    described_class.new collection_type, mongo_client
  end # let

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2).arguments }
  end # describe

  describe '#build' do
    it { expect(instance).to respond_to(:build).with(0).arguments }

    it 'should build a collection' do
      collection       = instance.build
      mongo_collection = mongo_client[collection_type.to_s]

      expect(collection).to be_a collection_class
      expect(collection.name).to be == collection_type.to_s
      expect(collection.mongo_collection).to be == mongo_collection
    end # it

    context 'when the collection type is a denormalized collection name' do
      let(:collection_type) { 'Resource' }

      it 'should build a collection' do
        collection       = instance.build
        mongo_collection = mongo_client['resources']

        expect(collection.mongo_collection).to be == mongo_collection
      end # it
    end # context

    context 'when the collection type is a named resource' do
      mock_class Spec, :Resource

      let(:collection_type) { Spec::Resource }

      it 'should build a collection' do
        collection       = instance.build
        mongo_collection = mongo_client['spec.resources']

        expect(collection.mongo_collection).to be == mongo_collection
      end # it
    end # context
  end # describe

  describe '#collection_class' do
    include_examples 'should have reader', :collection_class,
      ->() { collection_class }
  end # describe

  describe '#collection_name' do
    include_examples 'should have reader',
      :collection_name,
      ->() { be == collection_type.to_s }

    context 'when the collection type is a denormalized collection name' do
      let(:collection_type) { 'Resource' }

      it { expect(instance.collection_name).to be == 'resources' }
    end # context

    context 'when the collection type is a named resource' do
      mock_class Spec, :Resource

      let(:collection_type) { Spec::Resource }

      it { expect(instance.collection_name).to be == 'spec.resources' }
    end # context
  end # describe

  describe '#collection_type' do
    include_examples 'should have reader', :collection_type,
      ->() { be == collection_type }
  end # describe
end # describe
