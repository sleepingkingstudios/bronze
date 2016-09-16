# spec/patina/collections/simple/collection_builder_spec.rb

require 'patina/collections/simple/collection'
require 'patina/collections/simple/collection_builder'

RSpec.describe Patina::Collections::Simple::CollectionBuilder do
  let(:collection_class) do
    Patina::Collections::Simple::Collection
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
    it { expect(instance).to respond_to(:build).with(0..1).arguments }

    it 'should build a collection' do
      collection = instance.build

      expect(collection).to be_a collection_class
      expect(collection.name).to be == collection_type
      expect(collection.count).to be data[collection_type].count
    end # it
  end # describe

  describe '#collection_class' do
    include_examples 'should have reader', :collection_class,
      ->() { collection_class }
  end # describe

  describe '#collection_name' do
    include_examples 'should have reader', :collection_name,
      ->() { be == collection_type }
  end # describe

  describe '#collection_type' do
    include_examples 'should have reader', :collection_type,
      ->() { be == collection_type }
  end # describe
end # describe
