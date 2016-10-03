# spec/bronze/collections/reference/collection_builder_spec.rb

require 'bronze/collections/reference/collection'
require 'bronze/collections/reference/collection_builder'

RSpec.describe Bronze::Collections::Reference::CollectionBuilder do
  let(:collection_class) do
    Bronze::Collections::Reference::Collection
  end # let
  let(:data) do
    { collection_type => Array.new(3) { {} } }
  end # let
  let(:collection_type) { :resources }
  let(:instance)        { described_class.new collection_type, data }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2).arguments }
  end # describe

  describe '#build' do
    it { expect(instance).to respond_to(:build).with(0).arguments }

    it 'should build a collection' do
      collection = instance.build

      expect(collection).to be_a collection_class
      expect(collection.name).to be == collection_type.to_s
      expect(collection.count).to be data[collection_type].count
    end # it
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

      it { expect(instance.collection_name).to be == 'resources' }
    end # context
  end # describe

  describe '#collection_type' do
    include_examples 'should have reader', :collection_type,
      ->() { be == collection_type }
  end # describe
end # describe
